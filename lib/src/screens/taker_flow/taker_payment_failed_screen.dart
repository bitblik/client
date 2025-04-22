import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart';
import '../../services/api_service.dart';

class TakerPaymentFailedScreen extends ConsumerWidget {
  final Offer offer;

  const TakerPaymentFailedScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bolt11Controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Failed')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Payment Failed',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'The payment for ${offer.amountSats} sats could not be completed. '
              'Please provide a new Lightning invoice for the same amount.',
              textAlign: TextAlign.center,
            ),
            if (offer.takerLightningAddress != null &&
                offer.takerLightningAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Lightning address used: ${offer.takerLightningAddress}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: bolt11Controller,
              decoration: const InputDecoration(
                labelText: 'New Lightning Invoice',
                hintText: 'Enter your BOLT11 invoice',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newInvoice = bolt11Controller.text.trim();
                if (newInvoice.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid invoice'),
                    ),
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
                    final activeOffer = await apiService.getMyActiveOffer(
                      offer.takerPubkey ?? '',
                    );
                    if (activeOffer != null &&
                        activeOffer['status'] == 'takerPaid') {
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating invoice: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Submit New Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
