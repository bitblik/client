import 'dart:async';

import '../../../i18n/gen/strings.g.dart'; // Import Slang
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerPhase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/shared/logger/logger.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart';
import '../../widgets/progress_indicators.dart'; // Import for TakerProgressIndicator

class TakerWaitConfirmationScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const TakerWaitConfirmationScreen({required this.offer, super.key});

  @override
  ConsumerState<TakerWaitConfirmationScreen> createState() =>
      _TakerWaitConfirmationScreenState();
}

class _TakerWaitConfirmationScreenState
    extends ConsumerState<TakerWaitConfirmationScreen> {
  Timer? _confirmationTimer;
  int _confirmationCountdownSeconds = 120;
  bool _timersInitialized = false;
  bool _timerExpired = false;
  bool _makerReceivedBlik = false;
  Duration? _maxConfirmationTime;
  
  bool _isExpiredStatus(Offer offer) {
    return offer.statusEnum == OfferStatus.expiredBlik ||
           offer.statusEnum == OfferStatus.expiredSentBlik;
  }

  @override
  void initState() {
    super.initState();
    if (widget.offer.status != OfferStatus.blikReceived.name &&
        widget.offer.status != OfferStatus.blikSentToMaker.name &&
        widget.offer.status != OfferStatus.makerConfirmed.name &&
        widget.offer.status != OfferStatus.expiredBlik.name &&
        widget.offer.status != OfferStatus.expiredSentBlik.name) {
      Logger.log.d(
        "[TakerWaitConfirmation initState] Error: Received invalid offer state: ${widget.offer.status}. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resetToOfferList(
            t.taker.waitConfirmation.errors.invalidOfferStateReceived,
          );
        }
      });
    }
    
    // Fetch coordinator info for confirmation timeout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchCoordinatorInfo();
      }
    });
  }
  
  Future<void> _fetchCoordinatorInfo() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final coordinatorInfo = apiService.getCoordinatorInfoByPubkey(widget.offer.coordinatorPubkey);
      if (coordinatorInfo != null) {
        setState(() {
          _maxConfirmationTime = Duration(seconds: 120); // Default 2 minutes for BLIK confirmation
        });
      } else {
        setState(() {
          _maxConfirmationTime = const Duration(seconds: 120);
        });
      }
    } catch (e) {
      Logger.log.e("[TakerWaitConfirmation] Error fetching coordinator info: $e");
      setState(() {
        _maxConfirmationTime = const Duration(seconds: 120);
      });
    }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    super.dispose();
  }

  void _initializeOrUpdateCountdownTimer(Offer offer) {
    Logger.log.d("[TakerWaitConfirmation] Initializing/Updating countdown timer...");
    _startConfirmationTimer(offer);
    _timersInitialized = true;
  }

  void _startConfirmationTimer(Offer offer) {
    _confirmationTimer?.cancel();
    if (!mounted) return;

    final startTime = offer.blikReceivedAt ?? DateTime.now();
    final expiresAt = startTime.add(const Duration(seconds: 120));
    final now = DateTime.now();
    final initialRemaining = expiresAt.difference(now);

    Logger.log.d(
      "[TakerWaitConfirmation] Starting confirmation timer. Expires ~ $expiresAt",
    );

    if (initialRemaining.isNegative) {
      _handleConfirmationTimeout();
    } else {
      setState(() {
        _confirmationCountdownSeconds = initialRemaining.inSeconds.clamp(
          0,
          120,
        );
      });
      _confirmationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_confirmationCountdownSeconds > 0) {
            _confirmationCountdownSeconds--;
          } else {
            timer.cancel();
            _handleConfirmationTimeout();
          }
        });
      });
    }
  }

  void _handleConfirmationTimeout() {
    _confirmationTimer?.cancel();
    if (mounted) {
      Logger.log.d("[TakerWaitConfirmation] Confirmation timer expired.");
      setState(() {
        _timerExpired = true;
      });
    }
  }

  Future<void> _resetToOfferList(String message) async {
    _confirmationTimer?.cancel();
    // await ref.read(activeOfferProvider.notifier).setActiveOffer(null);
    ref.read(errorProvider.notifier).state = null;
    _timersInitialized = false;

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (scaffoldMessenger != null) {
            scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
          }
          if (navigator != null && navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        }
      });
    } else if (mounted) {
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
      context.go('/offers');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the active offer provider to get real-time status updates
    final t = Translations.of(context);
    final offer = ref.watch(activeOfferProvider);

    // Use addPostFrameCallback to handle navigation after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (offer == null) {
        Logger.log.d("[TakerWaitConfirmation] Active offer is null. Resetting.");
        _resetToOfferList(t.offers.status.cancelled);
        return;
      }

      final currentStatusEnum = offer.statusEnum;
      
      // Track when maker receives BLIK code
      if (currentStatusEnum == OfferStatus.blikSentToMaker && !_makerReceivedBlik) {
        setState(() {
          _makerReceivedBlik = true;
        });
      }

      if (currentStatusEnum == OfferStatus.makerConfirmed ||
          currentStatusEnum == OfferStatus.settled ||
          currentStatusEnum == OfferStatus.payingTaker ||
          currentStatusEnum == OfferStatus.takerPaid) {
        Logger.log.d(
          "[TakerWaitConfirmation] Status is $currentStatusEnum. Navigating to process screen.",
        );
          _confirmationTimer?.cancel();
          context.go("/paying-taker");
      } else if (currentStatusEnum == OfferStatus.invalidBlik) {
        _confirmationTimer?.cancel();
        context.go('/taker-invalid-blik', extra: offer);
      } else if (currentStatusEnum == OfferStatus.conflict) {
        _confirmationTimer?.cancel();
        context.go('/taker-conflict', extra: offer.id);
      } else if (currentStatusEnum == OfferStatus.takerPaymentFailed) {
          _confirmationTimer?.cancel();
          context.go('/paying-taker');
      } else if (currentStatusEnum != OfferStatus.blikReceived &&
          currentStatusEnum != OfferStatus.blikSentToMaker &&
          currentStatusEnum != OfferStatus.expiredBlik &&
          currentStatusEnum != OfferStatus.expiredSentBlik) {
        _resetToOfferList(
          t.offers.errors.unexpectedStateWithStatus(
            status: currentStatusEnum.name,
          ),
        );
      }
    });

    if (offer == null) {
      // Show a loading indicator while waiting for the offer or resetting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Initialize timer if not already done
    if (!_timersInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initializeOrUpdateCountdownTimer(offer);
      });
    }

    return Scaffold(
      body: _buildWaitingContent(context, offer),
    );
  }

  Widget _buildWaitingContent(BuildContext context, Offer offer) {
    final errorMessage = ref.watch(errorProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 3-Step Progress Indicator
          const TakerProgressIndicator(activeStep: 2),
          const SizedBox(height: 10),

          // Info message based on status - only show if timer hasn't expired
          if (!_timerExpired) ...[
            if (offer.statusEnum == OfferStatus.blikReceived) ...[
              // Waiting for maker to receive BLIK code
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.taker.waitConfirmation.waitingForMakerToReceive,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (_makerReceivedBlik) ...[
              // Maker has received BLIK code
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.taker.waitConfirmation.makerReceivedBlik,
                        style: const TextStyle(fontSize: 13, color: Colors.blue),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],

          // Instructional text - only show if timer hasn't expired and maker received BLIK
          if (!_timerExpired && offer.statusEnum == OfferStatus.blikSentToMaker) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.taker.waitConfirmation.instructions,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],

          // Circular Countdown Timer or Expired Icon
          if (_isExpiredStatus(offer))
            // Show expired icon for expired statuses
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.shade100,
              ),
              child: Icon(
                Icons.timer_off_outlined,
                size: 60,
                color: Colors.orange.shade700,
              ),
            )
          else if (offer.blikReceivedAt != null && _maxConfirmationTime != null && !_timerExpired)
            CircularCountdownTimer(
              size: 200,
              key: ValueKey('confirmation_timer_${offer.id}'),
              startTime: offer.blikReceivedAt!,
              maxDuration: _maxConfirmationTime!,
              strokeWidth: 16,
              progressColor: Colors.green,
              backgroundColor: Colors.white,
              fontSize: 48,
            )
          else if (_timerExpired)
            const Icon(Icons.timer_off, size: 100, color: Colors.red),

          const SizedBox(height: 10),

          // Important notice - only show if timer hasn't expired and maker has received BLIK
          if (!_timerExpired && offer.statusEnum == OfferStatus.blikSentToMaker)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.taker.waitConfirmation.importantBlikAmountConfirmation(
                        amount: formatDouble(offer.fiatAmount),
                        currency: offer.fiatCurrency,
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.orange),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),

          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 20),

          // Show expired status UI
          if (_isExpiredStatus(offer)) ...[
            // Expired title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                t.taker.waitConfirmation.expiredTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // Expired warning
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.taker.waitConfirmation.expiredWarning,
                      style: const TextStyle(fontSize: 14, color: Colors.orange),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionItem('1', t.taker.waitConfirmation.expiredInstruction1),
                  const SizedBox(height: 12),
                  _buildInstructionItem('2', t.taker.waitConfirmation.expiredInstruction2),
                  const SizedBox(height: 12),
                  _buildInstructionItem('3', t.taker.waitConfirmation.expiredInstruction3),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Renew Reservation button (green, primary action)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: isLoading ? null : () => _resendBlik(offer),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      const Icon(Icons.refresh, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      t.taker.waitConfirmation.expiredActions.renewReservation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Report Conflict button (red/warning)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: isLoading ? null : () => _reportConflict(offer),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      const Icon(Icons.report_problem_outlined, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        t.taker.waitConfirmation.expiredActions.reportConflict,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Cancel Reservation button (outlined)
            // Container(
            //   width: double.infinity,
            //   margin: const EdgeInsets.symmetric(horizontal: 20),
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: Colors.red,
            //       side: const BorderSide(color: Colors.red, width: 1),
            //       padding: const EdgeInsets.symmetric(vertical: 16),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //     ),
            //     onPressed: isLoading ? null : () => _cancelReservation(offer),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Container(
            //           width: 20,
            //           height: 20,
            //           decoration: const BoxDecoration(
            //             shape: BoxShape.circle,
            //             color: Colors.red,
            //           ),
            //           child: const Icon(Icons.close, size: 14, color: Colors.white),
            //         ),
            //         const SizedBox(width: 8),
            //         Text(
            //           t.taker.waitConfirmation.expiredActions.cancelReservation,
            //           style: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ]
          // Show warning and buttons if timer expired
          else if (_timerExpired) ...[
            // Warning message if maker has received BLIK (blikSentToMaker)
            if (offer.statusEnum == OfferStatus.blikSentToMaker) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.taker.waitConfirmation.timerExpiredMessage,
                        style: const TextStyle(fontSize: 13, color: Colors.orange),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Show action message and buttons if still in blikReceived status
            if (offer.statusEnum == OfferStatus.blikReceived) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.taker.waitConfirmation.timerExpiredActions,
                        style: const TextStyle(fontSize: 13, color: Colors.orange),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Resend BLIK button
              Container(
                width: double.infinity,
                height: 44,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF0000),
                      const Color(0xFFFF007F),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : () => _resendBlik(offer),
                    borderRadius: BorderRadius.circular(24),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading) ...[
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Icon(Icons.refresh, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            t.taker.waitConfirmation.resendBlikButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Reservation Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: isLoading ? null : () => _cancelReservation(offer),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.reservations.actions.cancel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _resendBlik(Offer offer) async {
    Logger.log.d(
      "[TakerInvalidBlikScreen] Retry selected for offer ${offer.id}",
    );

    final userPublicKey = await ref.read(
      publicKeyProvider.future,
    );

    final takerId = userPublicKey;
    final apiService = ref.read(apiServiceProvider);
    final DateTime? reservationTimestamp = await apiService
        .reserveOffer(
      offer.id,
      takerId!,
      offer.coordinatorPubkey,
    );

    if (reservationTimestamp != null) {
      final Offer updatedOffer = Offer(
        id: offer.id,
        amountSats: offer.amountSats,
        makerFees: offer.makerFees,
        fiatCurrency: offer.fiatCurrency,
        fiatAmount: offer.fiatAmount,
        coordinatorPubkey: offer.coordinatorPubkey,
        status: OfferStatus.reserved.name,
        createdAt: offer.createdAt,
        makerPubkey: offer.makerPubkey,
        takerPubkey: takerId,
        reservedAt: reservationTimestamp,
        blikReceivedAt: offer.blikReceivedAt,
        blikCode: offer.blikCode,
        holdInvoicePaymentHash: offer.holdInvoicePaymentHash,
      );


      await ref
          .read(activeOfferProvider.notifier)
          .setActiveOffer(updatedOffer);

      context.go("/submit-blik", extra: updatedOffer);
    } else {
      // Handle reservation failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.taker.invalidBlik.errors.reservationFailed,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    // // Navigate back to submit BLIK screen
    // _confirmationTimer?.cancel();
    // if (mounted) {
    //   context.go('/submit-blik', extra: offer);
    // }
  }

  Future<void> _reportConflict(Offer offer) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      Logger.log.i(
        "[TakerWaitConfirmation] Reporting conflict for offer ${offer.id}",
      );
      await apiService.markBlikCharged(
        offer.id,
        offer.coordinatorPubkey,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.taker.waitConfirmation.feedback.conflictReported),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/taker-conflict', extra: offer.id);
      }
    } catch (e) {
      Logger.log.e("[TakerWaitConfirmation] Error reporting conflict: $e");
      ref.read(errorProvider.notifier).state =
          t.taker.waitConfirmation.errors.reportingConflict(details: e.toString());
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _cancelReservation(Offer offer) async {
    final takerId = ref.read(publicKeyProvider).value;
    if (takerId == null) return;

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.cancelReservation(offer.id, takerId, offer.coordinatorPubkey);
      if (mounted) {
        _resetToOfferList(t.reservations.feedback.cancelled);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = t.reservations.errors.cancelling(error: e.toString());
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.shade100,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

String formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    String asString = value.toStringAsFixed(2);
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}
