import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

class TakerPaymentFailedScreen extends ConsumerWidget {
  final Offer offer;

  const TakerPaymentFailedScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bolt11Controller = TextEditingController();
    final strings = AppLocalizations.of(context)!; // Get strings

    // Calculate net amount
    final takerFees =
        offer.takerFees ?? (offer.amountSats * 0.005).ceil(); // Renamed
    final netAmountSats = offer.amountSats - takerFees; // Renamed

    return Scaffold(
      // Use localized string
      appBar: AppBar(title: Text(strings.paymentFailedTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            // Use localized string
            Text(
              strings.paymentFailedTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (offer.takerLightningAddress != null &&
                offer.takerLightningAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                // Use localized string (reuse existing key)
                child: Text(
                  strings.lightningAddressLabelShort(
                    offer.takerLightningAddress!,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 16),
            // Use localized string with placeholders
            Text(
              strings.paymentFailedInstructions(
                offer.amountSats,
                netAmountSats,
                takerFees,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: bolt11Controller,
              decoration: InputDecoration(
                // Use localized string
                labelText: strings.newLightningInvoiceLabel,
                // Use localized string
                hintText: strings.newLightningInvoiceHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newInvoice = bolt11Controller.text.trim();
                if (newInvoice.isEmpty) {
                  // Use localized string
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.errorEnterValidInvoice)),
                  );
                  return;
                }

                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  final apiService = ref.read(apiServiceProvider);
                  await apiService.updateTakerInvoice(
                    offerId: offer.id,
                    newBolt11: newInvoice,
                    userPubkey: offer.takerPubkey ?? '',
                  );

                  await apiService.retryTakerPayment(
                    offerId: offer.id,
                    userPubkey: offer.takerPubkey ?? '',
                  );

                  // Poll for takerPaid status
                  bool isPaid = false;
                  while (!isPaid) {
                    await Future.delayed(const Duration(seconds: 2));
                    final activeOfferStatus = await apiService.getOfferStatus(
                      offer.holdInvoicePaymentHash ?? '',
                    );
                    if (activeOfferStatus != null &&
                        activeOfferStatus == 'takerPaid') {
                      isPaid = true;
                    }
                  }

                  // Pop loading dialog and navigate back
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Pop loading dialog
                    Navigator.of(context).pop(); // Return to previous screen
                  }
                } catch (e) {
                  // Pop loading dialog
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    // Use localized string with placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.errorUpdatingInvoice(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              // Use localized string
              child: Text(strings.submitNewInvoiceButton),
            ),
          ],
        ),
      ),
    );
  }
}
