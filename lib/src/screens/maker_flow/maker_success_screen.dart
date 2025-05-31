import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../i18n/gen/strings.g.dart'; // Import Slang
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
    return Scaffold(
      appBar: AppBar(
        title: Text(t.maker.success.title),
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
              Text(
                t.maker.success.headline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                t.maker.success.subtitle,
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
                      Text(
                        t.maker.success.detailsTitle, // Corrected key
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Assuming a key like common.labels.amountSats exists or similar
                        // For now, using a generic approach, adjust if specific key exists
                        t.offers.details.amount(
                          amount: completedOffer.amountSats.toString(),
                        ),
                      ),
                      Text(
                        t.offers.details.makerFee(
                          fee: completedOffer.makerFees.toString(),
                        ),
                      ),
                      Text(
                        t.common.labels.status(
                          status: completedOffer.status.toUpperCase(),
                        ),
                      ),
                      Text(
                        t.offers.details.id(
                          id: completedOffer.id.substring(0, 8),
                        ),
                      ),
                      // Add more details if needed
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _goHome(context, ref),
                child: Text(t.common.buttons.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
