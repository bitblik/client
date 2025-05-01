import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import '../../providers/providers.dart'; // If needed for offer details
// import '../../models/offer.dart'; // If needed

class TakerConflictScreen extends ConsumerWidget {
  final String offerId;

  const TakerConflictScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // final offer = ref.watch(offerProvider(offerId)); // Example if offer details are needed

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.takerConflictTitle), // Needs localization string
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                l10n.takerConflictHeadline, // Needs localization string
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.takerConflictBody, // Needs localization string
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.takerConflictInstructions, // Needs localization string
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // TODO: Add contact/support information if applicable
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the main screen or offer list
                  context.go('/'); // Adjust route as needed
                },
                child: Text(l10n.takerConflictBackButton), // Needs localization string
              ),
            ],
          ),
        ),
      ),
    );
  }
}