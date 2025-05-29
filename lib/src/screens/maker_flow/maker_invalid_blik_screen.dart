import '../../gen/strings.g.dart'; // Import Slang
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../models/offer.dart';
import '../../providers/providers.dart'; // Import providers

class MakerInvalidBlikScreen extends ConsumerWidget {
  final Offer offer;

  const MakerInvalidBlikScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentHash = offer.holdInvoicePaymentHash;
    if (paymentHash == null) {
      print(
        "[MakerInvalidBlikScreen] Error: Payment hash is null, cannot poll status.",
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(t.common.error),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              t.taker.paymentProcess.errors.missingPaymentHash, // Re-using a similar error string
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      ref.listen<
        AsyncValue<OfferStatus?>
      >(pollingOfferStatusProvider(paymentHash), (previous, next) {
        next.whenData((status) {
          if (status == OfferStatus.conflict) {
            print(
              "[MakerInvalidBlikScreen] Offer status changed to conflict. Navigating...",
            );
            context.go('/maker-conflict', extra: offer);
          } else if (status == OfferStatus.reserved) {
            print(
              "[MakerInvalidBlikScreen] Offer status changed to reserved. Navigating back to wait-blik.",
            );
            context.go('/wait-blik', extra: offer);
          }
        });
      }); 
    } 

    return Scaffold(
      appBar: AppBar(
        title: Text(t.maker.invalidBlik.title),
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                t.maker.invalidBlik.info,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Text(
                // Using a generic offer ID display string
                t.offers.details.offerId(id: offer.id.substring(0, 8)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(), 
            ],
          ),
        ),
      ),
    );
  }
}
