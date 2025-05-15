import 'package:bitblik/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final offer = widget.offer;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invalidBlikTitle), // TODO: Add localization
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
                l10n.invalidBlikMessage, // TODO: Add localization
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                l10n.invalidBlikExplanation, // TODO: Add localization
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Option 1: Retry - Navigate back to submit BLIK screen
                  print(
                    "[TakerInvalidBlikScreen] Retry selected for offer ${offer.id}",
                  );

                  final userPublicKey = await ref.read(
                    publicKeyProvider.future,
                  ); // Corrected provider and await

                  final takerId = userPublicKey;
                  final apiService = ref.read(apiServiceProvider);
                  final DateTime? reservationTimestamp = await apiService
                      .reserveOffer(offer.id, takerId!);

                  if (reservationTimestamp != null) {
                    final Offer updatedOffer = Offer(
                      id: offer.id,
                      amountSats: offer.amountSats,
                      makerFees: offer.makerFees,
                      // Renamed
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
                  }

                  // Pass the same offer back to the submit screen
                  context.go('/submit-blik', extra: offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                // TODO: Add localization
                child: Text(l10n.invalidBlikRetryButton),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed:
                    _isLoading
                        ? null // Disable button while loading
                        : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          final apiService = ref.read(apiServiceProvider);
                          final userPublicKey = await ref.read(
                            publicKeyProvider.future,
                          ); // Corrected provider and await

                          if (userPublicKey == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.errorPublicKeyNotLoaded),
                                backgroundColor: Colors.red,
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
                              userPublicKey,
                            );

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                // Removed const
                                content: Text(
                                  l10n.conflictReportedSuccess,
                                ), // Use localization
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Don't clear active offer, just navigate to conflict screen
                            // ref.read(activeOfferProvider.notifier).state = null;
                            if (mounted) {
                              // Navigate to conflict screen, passing the offer ID
                              context.go('/taker-conflict', extra: offer.id);
                            }
                          } catch (e) {
                            print(
                              "[TakerInvalidBlikScreen] Error reporting conflict: $e",
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.conflictReportError(
                                    e.toString(),
                                  ), // Use positional argument
                                ), // Use localization
                                backgroundColor: Colors.red,
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
                  backgroundColor: Colors.red,
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
                        : Text(l10n.invalidBlikConflictButton),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Go back to offer list
                  ref.read(activeOfferProvider.notifier).state = null;
                  context.go('/offers');
                },
                // TODO: Add localization
                child: Text(l10n.cancelAndReturnHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
