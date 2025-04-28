import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import '../../models/offer.dart';
import '../../providers/providers.dart'; // To reset state

class MakerSuccessScreen extends ConsumerWidget {
  final Offer completedOffer;

  const MakerSuccessScreen({required this.completedOffer, super.key});

  void _goHome(BuildContext context, WidgetRef ref) {
    // Reset relevant state providers before going home
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(holdInvoiceProvider.notifier).state = null;
    ref.read(paymentHashProvider.notifier).state = null;
    ref.read(receivedBlikCodeProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    ref.read(isLoadingProvider.notifier).state = false;
    ref.invalidate(availableOffersProvider); // Invalidate offer list

    context.go('/');
    // Navigate back to the root (RoleSelectionScreen)
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!; // Get strings

    return Scaffold(
      appBar: AppBar(
        // Use localized string
        title: Text(strings.offerCompletedTitle),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 20),
              // Use localized string
              Text(
                strings.paymentConfirmedHeadline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Use localized string
              Text(
                strings.takerPaidSubtitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use localized string
                      Text(
                        strings.offerDetailsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Already localized
                        strings.amountSats(
                          completedOffer.amountSats.toString(),
                        ),
                      ),
                      Text(
                        // Already localized
                        strings.makerFeeSats(
                          completedOffer.makerFees.toString(),
                        ),
                      ),
                      // Use the status string directly
                      Text(
                        // Already localized
                        strings.status(completedOffer.status.toUpperCase()),
                      ),
                      // Use localized string with placeholder
                      Text(
                        strings.offerIdLabel(completedOffer.id.substring(0, 8)),
                      ),
                      // Add more details if needed
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _goHome(context, ref),
                // Use localized string (already exists)
                child: Text(strings.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
