import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Use Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../models/offer.dart';
import '../../providers/providers.dart'; // Import providers
// import '../../widgets/offer_details_card.dart'; // Widget does not exist yet

class MakerInvalidBlikScreen extends ConsumerWidget {
  // Change to ConsumerWidget
  final Offer offer;

  const MakerInvalidBlikScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    final appLocalizations = AppLocalizations.of(context)!;

    // Ensure payment hash exists before listening
    final paymentHash = offer.holdInvoicePaymentHash;
    if (paymentHash == null) {
      // This should ideally not happen in this state, but handle defensively
      print(
        "[MakerInvalidBlikScreen] Error: Payment hash is null, cannot poll status.",
      );
      // Return a Scaffold with an error message
      return Scaffold(
        appBar: AppBar(
          title: Text(appLocalizations.error),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              appLocalizations
                  .errorMissingPaymentHash, // Use a relevant error string
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else {
      // Listen to the polling provider for status changes using paymentHash
      ref.listen<
        AsyncValue<OfferStatus?>
      >(pollingOfferStatusProvider(paymentHash), (previous, next) {
        next.whenData((status) {
          if (status == OfferStatus.conflict) {
            // Changed comparison to enum value
            print(
              "[MakerInvalidBlikScreen] Offer status changed to conflict. Navigating...",
            );
            // Navigate to the maker conflict screen
            context.go('/maker-conflict', extra: offer.id);
          } else if (status == OfferStatus.reserved) {
            // Taker chose to retry, go back to waiting for BLIK
            print(
              "[MakerInvalidBlikScreen] Offer status changed to reserved. Navigating back to wait-blik.",
            );
            context.go('/wait-blik', extra: offer);
          }
          // TODO: Handle other potential status changes? E.g., if Taker cancels?
        });
        // Optional: Handle loading/error states if needed
      }); // Close the ref.listen callback function
    } // Close the else block

    // Access providers using ref if needed, e.g.:
    // final apiService = ref.read(apiServiceProvider);
    // final coordinatorService = ref.read(coordinatorServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.makerInvalidBlikTitle),
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // OfferDetailsCard(offer: offer), // Removed non-existent widget
              // const SizedBox(height: 24),
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                appLocalizations.makerInvalidBlikInfo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              // Display the offer ID for reference
              Text(
                "Offer ID: ${offer.id.substring(0, 8)}...",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(), // Show progress while waiting
              // No button needed here, the screen waits for status change
            ],
          ),
        ),
      ),
    );
  }
}
