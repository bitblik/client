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
    super.dispose();
  }

  void _startStatusCheckTimer({bool checkImmediately = false}) {
    // No longer need timer - will use subscription instead
  }

  void _handleStatusUpdate(OfferStatus? status) async {
    if (status == null) return;

    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;
    final coordinatorPubkey = offer?.coordinatorPubkey;

    if (offer == null || makerId == null || coordinatorPubkey == null) {
      if (offer == null && mounted) {
        _resetToRoleSelection(t.maker.waitTaker.errorActiveOfferDetailsLost);
      }
      return;
    }

    print("[MakerWaitTaker] Status update received: $status");

    if (status == OfferStatus.reserved) {
      if (mounted) {
        context.go('/wait-blik');
      }
    } else if (status == OfferStatus.funded) {
      // Continue waiting
    } else if (status == OfferStatus.blikReceived ||
        status == OfferStatus.blikSentToMaker) {
      try {
        final apiService = ref.read(apiServiceProvider);
        final blikCode = await apiService.getBlikCodeForMaker(
          offer.id,
          makerId,
          coordinatorPubkey,
        );
        if (blikCode != null && blikCode.isNotEmpty) {
          ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
          if (mounted) {
            context.go('/confirm-blik');
          }
        } else {
          if (mounted) {
            _resetToRoleSelection(t.maker.waitTaker.errorFailedToRetrieveBlik);
          }
        }
      } catch (e) {
        if (mounted) {
          _resetToRoleSelection(
            t.maker.waitTaker.errorRetrievingBlik(details: e.toString()),
          );
        }
      }
    } else if (status == OfferStatus.expired) {
      if (mounted) {
        _resetToRoleSelection(
          t.maker.waitTaker.offerNoLongerAvailable(status: status.name),
        );
      }
    } else {
      if (mounted) {
        _resetToRoleSelection(
          t.maker.waitTaker.offerNoLongerAvailable(status: status.name),
        );
      }
    }
  }

  Future<void> _resetToRoleSelection(String message) async {
    await ref.read(activeOfferProvider.notifier).setActiveOffer(null);
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
    final makerPubKey = ref.read(publicKeyProvider).value;

    if (offer == null || makerPubKey == null) {
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
      await apiService.cancelOffer(offer.id, offer.coordinatorPubkey);
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
    final publicKeyAsync = ref.watch(publicKeyProvider);

    // Set up status subscription
    if (offer != null &&
        offer.holdInvoicePaymentHash != null &&
        offer.coordinatorPubkey != null) {
      publicKeyAsync.whenData((publicKey) {
        if (publicKey != null) {
          ref.listen<AsyncValue<OfferStatus?>>(
            offerStatusSubscriptionProvider((
              paymentHash: offer.holdInvoicePaymentHash!,
              coordinatorPubKey: offer.coordinatorPubkey!,
              userPubkey: publicKey,
            )),
            (previous, next) {
              next.whenData((status) {
                _handleStatusUpdate(status);
              });
            },
          );
        }
      });
    }

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
