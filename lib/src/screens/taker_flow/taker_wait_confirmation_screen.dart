import 'dart:async';

import 'package:bitblik/l10n/app_localizations.dart';
import 'package:bitblik/src/screens/taker_flow/taker_payment_failed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerPhase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart';

class TakerWaitConfirmationScreen extends ConsumerStatefulWidget {
  final Offer offer; // Accept the offer directly - REINSTATED

  const TakerWaitConfirmationScreen({
    required this.offer,
    super.key,
  }); // REINSTATED

  @override
  ConsumerState<TakerWaitConfirmationScreen> createState() =>
      _TakerWaitConfirmationScreenState();
}

class _TakerWaitConfirmationScreenState
    extends ConsumerState<TakerWaitConfirmationScreen> {
  Timer? _confirmationTimer;
  int _confirmationCountdownSeconds = 120;
  // Timer? _statusCheckTimer; // REMOVED
  // bool _isCheckingStatus = false; // REMOVED
  bool _timersInitialized = false; // Keep for countdown timer init

  @override
  void initState() {
    super.initState();
    // Validate passed offer immediately
    if (widget.offer.status != OfferStatus.blikReceived.name &&
        widget.offer.status != OfferStatus.blikSentToMaker.name &&
        widget.offer.status != OfferStatus.makerConfirmed.name) {
      print(
        "[TakerWaitConfirmation initState] Error: Received invalid offer state: ${widget.offer.status}. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Use localized string
          final strings = AppLocalizations.of(context)!;
          _resetToOfferList(strings.errorInvalidOfferStateReceived);
        }
      });
    }
    // REMOVED timer initialization from initState
    // else {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       _initializeOrUpdateCountdownTimer(widget.offer);
    //     }
    //   });
    // }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    // _statusCheckTimer?.cancel(); // REMOVED
    super.dispose();
  }

  // Renamed and simplified: only initializes countdown timer now
  void _initializeOrUpdateCountdownTimer(Offer offer) {
    // if (_timersInitialized || !mounted) return; // Allow re-initialization/update
    print("[TakerWaitConfirmation] Initializing/Updating countdown timer...");
    _startConfirmationTimer(offer); // Pass offer
    // _startStatusCheckTimer(offer); // REMOVED
    _timersInitialized = true; // Set flag after starting countdown
  }

  // --- Confirmation Timer (120s) ---
  // Renamed for clarity
  void _startConfirmationTimer(Offer offer) {
    // Accept offer
    // if (_confirmationTimer?.isActive ?? false) return; // Allow restart if needed
    _confirmationTimer?.cancel(); // Cancel previous timer if any
    if (!mounted) return;

    final startTime = offer.blikReceivedAt ?? DateTime.now(); // Use offer data
    final expiresAt = startTime.add(const Duration(seconds: 120));
    final now = DateTime.now();
    final initialRemaining = expiresAt.difference(now);

    print(
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
    // _statusCheckTimer?.cancel(); // REMOVED
    if (mounted) {
      print("[TakerWaitConfirmation] Confirmation timer expired.");
      // Resetting should be handled by provider state change now
      // ref.read(activeOfferProvider.notifier).state = null;
      // _resetToOfferList('Maker confirmation timed out (120s).');
    }
  }

  // --- Status Check Timer --- REMOVED ---
  // void _startStatusCheckTimer(Offer offer) { ... } // REMOVED
  // Future<void> _checkOfferStatus() async { ... } // REMOVED

  // _handlePaymentSuccess method removed as navigation is handled directly

  // Keep the _resetToOfferList method for now, might be useful for error handling
  void _resetToOfferList(String message) {
    _confirmationTimer?.cancel();
    // _statusCheckTimer?.cancel(); // REMOVED
    ref.read(activeOfferProvider.notifier).state =
        null; // Keep this to clear state
    ref.read(errorProvider.notifier).state = null; // Keep this to clear error
    _timersInitialized = false; // Reset flag

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
    final l10n = AppLocalizations.of(context)!;
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);

    return Scaffold(
      // Add AppBar for consistency
      appBar: AppBar(
        title: Text(l10n.waitingForBlik), // Reuse existing title
        automaticallyImplyLeading: false, // Prevent back navigation
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: l10n.goHome,
            onPressed: () {
              _resetToOfferList('Navigated home.'); // Use reset to clear state
            },
          ),
        ],
      ),
      body: publicKeyAsyncValue.when(
        data: (publicKey) {
          if (publicKey == null) {
            return Center(child: Text(l10n.errorNoPublicKey));
          }
          // Watch the polling provider
          final offerAsyncValue = ref.watch(
            pollingMyActiveOfferProvider(publicKey),
          );

          return offerAsyncValue.when(
            data: (offer) {
              if (offer == null) {
                // Offer might be null if not found or in a non-active state initially/during poll
                // This might happen if the offer expires/is cancelled and the provider returns null
                print(
                  "[TakerWaitConfirmation build] Polling provider returned null offer. Resetting.",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _resetToOfferList(l10n.offerCancelledOrExpired);
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(key: Key("resetting_null")),
                );
              }

              // --- Handle Navigation based on Status ---
              final currentStatusEnum = offer.statusEnum;

              if (currentStatusEnum == OfferStatus.makerConfirmed ||
                  currentStatusEnum == OfferStatus.settled ||
                  currentStatusEnum == OfferStatus.payingTaker ||
                  currentStatusEnum == OfferStatus.takerPaid) {
                print(
                  "[TakerWaitConfirmation build] Status is $currentStatusEnum. Navigating to process screen.",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    // Set the payment hash before navigating
                    final paymentHash = offer.holdInvoicePaymentHash;
                    if (paymentHash != null) {
                      ref.read(paymentHashProvider.notifier).state =
                          paymentHash;
                      _confirmationTimer?.cancel(); // Stop timer
                      context.go("/paying-taker");
                    } else {
                      print(
                        "[TakerWaitConfirmation build] CRITICAL: Payment hash is null before navigating to process screen. Resetting.",
                      );
                      _resetToOfferList(l10n.errorInternalOfferIncomplete);
                    }
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(key: Key("navigating_pay")),
                ); // Show loading while navigating
              } else if (currentStatusEnum == OfferStatus.invalidBlik) {
                // --- NEW: Handle Invalid BLIK ---
                print(
                  "[TakerWaitConfirmation build] Status is invalidBlik. Navigating to invalid BLIK screen.",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _confirmationTimer?.cancel(); // Stop timer
                    // Navigate to the new TakerInvalidBlikScreen
                    context.go('/taker-invalid-blik', extra: offer);
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(
                    key: Key("navigating_invalid_blik"),
                  ),
                ); // Show loading while navigating
                // --- END NEW ---
              } else if (currentStatusEnum == OfferStatus.conflict) {
                // --- NEW: Handle Conflict ---
                print(
                  "[TakerWaitConfirmation build] Status is conflict. Navigating to conflict screen.",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _confirmationTimer?.cancel(); // Stop timer
                    // Navigate to the TakerConflictScreen
                    context.go(
                      '/taker-conflict',
                      extra: offer.id,
                    ); // Pass offerId
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(
                    key: Key("navigating_conflict"),
                  ),
                ); // Show loading while navigating
                // --- END NEW ---
              } else if (currentStatusEnum == OfferStatus.takerPaymentFailed) {
                print(
                  "[TakerWaitConfirmation build] Status is takerPaymentFailed. Navigating to process screen (to show failure).",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _confirmationTimer?.cancel(); // Stop timer
                    // Set payment hash before navigating to process screen
                    final paymentHash = offer.holdInvoicePaymentHash;
                    if (paymentHash != null) {
                      ref.read(paymentHashProvider.notifier).state =
                          paymentHash;
                      context.go('/paying-taker'); // Navigate to process screen
                    } else {
                      print(
                        "[TakerWaitConfirmation build] CRITICAL: Payment hash is null before navigating to process screen for failure. Resetting.",
                      );
                      _resetToOfferList(l10n.errorInternalOfferIncomplete);
                    }
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(key: Key("navigating_fail")),
                ); // Show loading while navigating
              } else if (currentStatusEnum != OfferStatus.blikReceived &&
                  currentStatusEnum != OfferStatus.blikSentToMaker) {
                // If status is something else unexpected (funded, expired, cancelled), reset.
                print(
                  "[TakerWaitConfirmation build] Offer status ($currentStatusEnum) invalid for waiting screen. Resetting.",
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _resetToOfferList(
                      l10n.errorOfferUnexpectedStateWithStatus(
                        currentStatusEnum.name,
                      ),
                    );
                  }
                });
                return const Center(
                  child: CircularProgressIndicator(
                    key: Key("resetting_invalid"),
                  ),
                ); // Show loading while resetting
              }
              // --- End Navigation Handling ---

              // --- Initialize/Update Countdown Timer ---
              // Only start/update if the status is correct for this screen
              // and the timer hasn't been initialized yet OR if the offer data changed
              // (Checking _timersInitialized prevents restarting timer unnecessarily on every rebuild)
              // We might need to re-evaluate if the offer object itself changes significantly
              // while status remains blikReceived/blikSentToMaker.
              if (!_timersInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _initializeOrUpdateCountdownTimer(offer);
                });
              }
              // --- End Timer Handling ---

              // --- Render Waiting UI ---
              return _buildWaitingContent(context, offer);
            },
            loading:
                () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.loadingOfferDetails),
                    ],
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 16),
                      Text(l10n.errorLoadingOffer(error.toString())),
                      // Optionally add a retry button?
                    ],
                  ),
                ),
          );
        },
        loading:
            () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.loadingPublicKey),
                ],
              ),
            ),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(l10n.errorLoadingPublicKey),
                  Text(error.toString()),
                ],
              ),
            ),
      ),
    );
  }

  // Extracted UI building logic
  Widget _buildWaitingContent(BuildContext context, Offer offer) {
    final l10n = AppLocalizations.of(context)!;
    // final isLoading = ref.watch(isLoadingProvider); // isLoadingProvider might not be needed anymore
    final errorMessage = ref.watch(
      errorProvider,
    ); // Keep watching for general errors

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (errorMessage != null) ...[
              Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            // Use localized string with placeholder
            Text(
              l10n.offerStatusLabel(offer.status), // Use offer from parameter
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Use localized string with placeholder
            Text(
              l10n.waitingMakerConfirmation(_confirmationCountdownSeconds),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    _confirmationCountdownSeconds <= 15
                        ? Colors.orange
                        : Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            // Use localized string with placeholders
            Text(
              l10n.importantBlikAmountConfirmation(
                formatDouble(offer.fiatAmount), // Use offer from parameter
                offer.fiatCurrency, // Use offer from parameter
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // isLoading check removed
            const Center(
              child: Icon(Icons.timer_outlined, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Use localized string
            Text(l10n.blikInstructionsTaker, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Keep formatDouble helper function
String formatDouble(double value) {
  // Check if the value is effectively a whole number
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    // Format with up to 2 decimal places, removing trailing zeros
    String asString = value.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      // Remove decimal point if it's the last character
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}
