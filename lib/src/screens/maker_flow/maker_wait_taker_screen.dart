import 'dart:async';

import 'package:flutter/material.dart';
import '../../../i18n/gen/strings.g.dart'; // Correct Slang import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart'; // For OfferStatus enum
import '../../providers/providers.dart';
import '../../widgets/progress_indicators.dart';

class MakerWaitTakerScreen extends ConsumerStatefulWidget {
  const MakerWaitTakerScreen({super.key});

  @override
  ConsumerState<MakerWaitTakerScreen> createState() =>
      _MakerWaitTakerScreenState();
}

class _MakerWaitTakerScreenState extends ConsumerState<MakerWaitTakerScreen> {
  Timer? _statusCheckTimer;
  bool _isChecking = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startStatusCheckTimer();
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheckTimer({bool checkImmediately = false}) {
    _statusCheckTimer?.cancel();
    if (checkImmediately) {
      _checkOfferStatus();
    }
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isChecking) {
        await _checkOfferStatus();
      }
    });
  }

  Future<void> _checkOfferStatus() async {
    if (_isChecking) return;

    final offer = ref.read(activeOfferProvider);
    final paymentHash = offer?.holdInvoicePaymentHash;
    final makerId = ref.read(publicKeyProvider).value;

    if (paymentHash == null || makerId == null || offer == null) {
      if (offer == null && mounted) {
        _resetToRoleSelection(t.maker.waitTaker.errorActiveOfferDetailsLost);
      }
      return;
    }

    _isChecking = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final statusString = await apiService.getOfferStatus(paymentHash);

      if (statusString == null) {
        return;
      }

      var currentStatus = OfferStatus.values.byName(statusString);

      if (offer.status != currentStatus.name) {
        final updatedOfferData = await apiService.getMyActiveOffer(makerId);
        if (updatedOfferData != null) {
          final updatedOffer = Offer.fromJson(updatedOfferData);
          ref.read(activeOfferProvider.notifier).state = updatedOffer;
          if (updatedOffer.status == OfferStatus.reserved.name) {
            currentStatus = OfferStatus.reserved;
          }
        }
      }

      if (currentStatus == OfferStatus.reserved) {
        _statusCheckTimer?.cancel();
        if (mounted) {
          context.go('/wait-blik');
          if (mounted) {
            final currentOfferState = ref.read(activeOfferProvider);
            if (currentOfferState != null &&
                (currentOfferState.status == OfferStatus.funded.name)) {
              _startStatusCheckTimer();
            }
          }
        }
      } else if (currentStatus == OfferStatus.funded) {
        // Timer continues
      } else if (currentStatus == OfferStatus.blikReceived ||
          currentStatus == OfferStatus.blikSentToMaker) {
        _statusCheckTimer?.cancel();
        try {
          final String offerId = offer.id;
          final blikCode = await apiService.getBlikCodeForMaker(
            offerId,
            makerId,
          );
          if (blikCode != null && blikCode.isNotEmpty) {
            ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
            if (mounted) {
              context.go('/confirm-blik');
            }
          } else {
            if (mounted) {
              _resetToRoleSelection(
                t.maker.waitTaker.errorFailedToRetrieveBlik,
              );
            }
          }
        } catch (e) {
          if (mounted) {
            _resetToRoleSelection(
              t.maker.waitTaker.errorRetrievingBlik(details: e.toString()),
            );
          }
        }
      } else if (currentStatus == OfferStatus.expired) {
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(
            t.maker.waitTaker.offerNoLongerAvailable(
              status: currentStatus.name,
            ),
          );
        }
      } else {
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(
            t.maker.waitTaker.offerNoLongerAvailable(
              status: currentStatus.name,
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  void _resetToRoleSelection(String message) {
    _statusCheckTimer?.cancel();
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(holdInvoiceProvider.notifier).state = null;
    ref.read(paymentHashProvider.notifier).state = null;
    ref.read(receivedBlikCodeProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
        }
        context.go("/");
      }
    });
  }

  Future<void> _cancelOffer() async {
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;

    if (offer == null || makerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.maker.waitTaker.errorCouldNotIdentifyOffer)),
        );
      }
      return;
    }
    if (offer.status != OfferStatus.funded.name) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.maker.waitTaker.offerCannotBeCancelled(status: offer.status),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isCancelling = true;
    });
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.cancelOffer(offer.id, makerId);
      _resetToRoleSelection(t.maker.waitTaker.offerCancelledSuccessfully);
    } catch (e) {
      if (mounted) {
        final errorMsg = t.maker.waitTaker.failedToCancelOffer(
          details: e.toString(),
        );
        ref.read(errorProvider.notifier).state = errorMsg;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(activeOfferProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (offer != null) ...[
              Text(
                t.offers.display.yourOffer, // Changed to common key
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                // Common key
                t.offers.details.amount(amount: offer.amountSats.toString()),
              ),
              Text(
                // Common key
                t.offers.details.makerFee(fee: offer.makerFees.toString()),
              ),
              Text(
                // Common key
                t.common.labels.status(status: offer.status.toUpperCase()),
              ),
              const SizedBox(height: 30),
            ],
            if (offer != null && offer.status == OfferStatus.funded.name)
              FundedOfferProgressIndicator(
                key: ValueKey('progress_funded_${offer.id}'),
                createdAt: offer.createdAt,
              ),
            Text(
              t
                  .maker
                  .waitTaker
                  .message, // Changed to use existing YAML key 'message'
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (offer == null || offer.status != OfferStatus.funded.name)
              const CircularProgressIndicator(),
            const SizedBox(height: 40),
            Consumer(
              builder: (context, ref, _) {
                final error = ref.watch(errorProvider);
                if (error != null &&
                    error.startsWith(
                      // Specific key
                      t.maker.waitTaker
                          .failedToCancelOffer(details: '')
                          .split(' {details}')[0],
                    )) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ElevatedButton(
              onPressed:
                  _isCancelling ||
                          (offer != null &&
                              offer.status != OfferStatus.funded.name)
                      ? null
                      : _cancelOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child:
                  _isCancelling
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(
                        t.offers.actions.cancel, // Changed to common key
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
