import '../../../i18n/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart'; // Import providers

class TakerInvalidBlikScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const TakerInvalidBlikScreen({required this.offer, super.key});

  @override
  ConsumerState<TakerInvalidBlikScreen> createState() =>
      _TakerInvalidBlikScreenState();
}

class _TakerInvalidBlikScreenState
    extends ConsumerState<TakerInvalidBlikScreen> {
  bool _isLoading = false; // State variable for loading indicator

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.taker.invalidBlik.title),
        automaticallyImplyLeading: false, // Prevent back navigation
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                t.taker.invalidBlik.message,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                t.taker.invalidBlik.explanation,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  print(
                    "[TakerInvalidBlikScreen] Retry selected for offer ${offer.id}",
                  );

                  final userPublicKey = await ref.read(
                    publicKeyProvider.future,
                  );

                  final takerId = userPublicKey;
                  final apiService = ref.read(apiServiceProvider);
                  final DateTime? reservationTimestamp = await apiService
                      .reserveOffer(offer.id, takerId!);

                  if (reservationTimestamp != null) {
                    final Offer updatedOffer = Offer(
                      id: offer.id,
                      amountSats: offer.amountSats,
                      makerFees: offer.makerFees,
                      fiatCurrency: offer.fiatCurrency,
                      fiatAmount: offer.fiatAmount,
                      status: OfferStatus.reserved.name,
                      createdAt: offer.createdAt,
                      makerPubkey: offer.makerPubkey,
                      takerPubkey: takerId,
                      reservedAt: reservationTimestamp,
                      blikReceivedAt: offer.blikReceivedAt,
                      blikCode: offer.blikCode,
                      holdInvoicePaymentHash: offer.holdInvoicePaymentHash,
                    );

                    ref.read(activeOfferProvider.notifier).state = updatedOffer;
                    ref.read(appRoleProvider.notifier).state = AppRole.taker;

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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.taker.invalidBlik.actions.retry),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          final apiService = ref.read(apiServiceProvider);
                          final userPublicKey = await ref.read(
                            publicKeyProvider.future,
                          );

                          if (userPublicKey == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t
                                      .maker
                                      .confirmPayment
                                      .errors
                                      .missingHashOrKey,
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                            return;
                          }

                          try {
                            print(
                              "[TakerInvalidBlikScreen] Calling blikChargedByTaker for offer ${offer.id} by taker $userPublicKey",
                            );
                            // Replace markOfferConflict with blikChargedByTaker
                            final result = await apiService.blikChargedByTaker(
                              offer.id,
                              userPublicKey,
                            );
                            final message =
                                result['message'] as String? ?? 'Success';
                            final newStatusString =
                                result['new_status'] as String?;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message), // Use message from API
                                backgroundColor: Colors.green,
                              ),
                            );

                            OfferStatus? newStatus;
                            if (newStatusString != null) {
                              try {
                                newStatus = OfferStatus.values.byName(
                                  newStatusString,
                                );
                              } catch (_) {
                                print(
                                  'Invalid new status received: $newStatusString',
                                );
                              }
                            }

                            if (mounted) {
                              if (newStatus != null) {
                                final updatedOffer = offer.copyWith(
                                  status: newStatus.name,
                                );
                                ref.read(activeOfferProvider.notifier).state =
                                    updatedOffer;

                                if (newStatus == OfferStatus.conflict) {
                                  context.go(
                                    '/taker-conflict',
                                    extra: offer.id,
                                  );
                                } else if (newStatus ==
                                    OfferStatus.takerConfirmed) {
                                  // Navigate to wait confirmation, which handles takerConfirmed
                                  context.go(
                                    '/wait-confirmation',
                                    extra: updatedOffer,
                                  );
                                } else {
                                  // Fallback or handle other statuses if necessary
                                  // For now, if it's not conflict or takerConfirmed,
                                  // the activeOfferProvider is updated, and router should handle it.
                                  // Or, navigate to a general screen like offers list.
                                  print(
                                    "Offer ${offer.id} status changed to $newStatus, activeOfferProvider updated.",
                                  );
                                  // Potentially context.go('/offers'); if no specific screen for newStatus
                                }
                              } else {
                                // If no new status, refresh current offer from provider or stay
                                // For now, assume the message indicates success and we might want to
                                // navigate to a waiting screen or refresh.
                                // Given this is "BLIK charged", /wait-confirmation is a sensible default
                                // if the status didn't explicitly change to conflict.
                                // Update the local offer state and navigate.
                                // The polling provider on TakerWaitConfirmationScreen will handle subsequent updates.
                                final currentOffer = ref.read(
                                  activeOfferProvider,
                                );
                                if (currentOffer != null) {
                                  // Potentially update status if known, otherwise use existing
                                  // For now, assume no status change if newStatusString was null
                                  ref.read(activeOfferProvider.notifier).state =
                                      currentOffer;
                                  context.go(
                                    '/wait-confirmation',
                                    extra: currentOffer,
                                  );
                                } else {
                                  // Fallback if activeOffer is somehow null
                                  context.go('/offers');
                                }
                              }
                            }
                          } catch (e) {
                            print(
                              "[TakerInvalidBlikScreen] Error calling blikChargedByTaker: $e",
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.taker.invalidBlik.errors.conflictReport(
                                    details: e.toString(),
                                  ),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        // Use the same text as in TakerExpiredSentBlikScreen for consistency
                        : Text(t.taker.expiredSentBlikScreen.blikUsedButton),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ref.read(activeOfferProvider.notifier).state = null;
                  context.go('/offers');
                },
                child: Text(t.common.actions.cancelAndReturnToOffers),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
