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
                              "[TakerInvalidBlikScreen] Reporting conflict for offer ${offer.id} by taker $userPublicKey",
                            );
                            await apiService.markOfferConflict(
                              offer.id,
                              offer.coordinatorPubkey,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  t
                                      .taker
                                      .invalidBlik
                                      .feedback
                                      .conflictReportedSuccess,
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            if (mounted) {
                              context.go('/taker-conflict', extra: offer.id);
                            }
                          } catch (e) {
                            print(
                              "[TakerInvalidBlikScreen] Error reporting conflict: $e",
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
                        : Text(t.taker.invalidBlik.actions.reportConflict),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  // PILA no no no, we should cancel the reservation and go back to funded, TODO!!!!
                  // await ref
                  //     .read(activeOfferProvider.notifier)
                  //     .setActiveOffer(null);
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
