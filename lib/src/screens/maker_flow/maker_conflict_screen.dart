
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MakerConflictScreen extends ConsumerWidget {
  final String offerId;

  const MakerConflictScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // Use a unique title for Maker's conflict view
        title: Text(l10n.makerConflictTitle), // Needs localization string
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.gavel_rounded, // Different icon?
                  size: 80,
                  color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                l10n.makerConflictHeadline, // Needs localization string
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.makerConflictBody, // Needs localization string
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.makerConflictInstructions, // Needs localization string
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Consider adding offer details if needed later
              // Text("Offer ID: ${offerId.substring(0, 8)}..."),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Reset active offer state? Maybe not, let user see it on home screen.
                  // ref.read(activeOfferProvider.notifier).state = null;
                  // Navigate back to the main screen or offer list
                  context.go('/'); // Go to root/role selection
                },
                // Use a unique button text for Maker's conflict view
                child: Text(l10n.makerConflictBackButton), // Needs localization string
              ),
            ],
          ),
        ),
      ),
    );
  }
}
