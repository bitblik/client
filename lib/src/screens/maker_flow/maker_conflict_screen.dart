import '../../../i18n/gen/strings.g.dart'; // Import Slang
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart';

class MakerConflictScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const MakerConflictScreen({super.key, required this.offer});

  @override
  ConsumerState<MakerConflictScreen> createState() =>
      _MakerConflictScreenState();
}

class _MakerConflictScreenState extends ConsumerState<MakerConflictScreen> {
  // bool _isDisputeOpened = false; // Removed
  // final _formKey = GlobalKey<FormState>(); // Not used currently
  // final _lnAddressController = TextEditingController(); // Not used currently

  // @override
  // void dispose() {
  //   _lnAddressController.dispose(); // Not used currently
  //   super.dispose();
  // }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final makerId = await ref.read(publicKeyProvider.future);

    if (makerId == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(t.maker.amountForm.errors.publicKeyNotLoaded)),
      );
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      await apiService.confirmMakerPayment(widget.offer.id, makerId);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(t.maker.confirmPayment.feedback.confirmedTakerPaid),
        ),
      );
      context.go('/maker-success', extra: widget.offer);
    } catch (e) {
      final errorMsg = t.maker.confirmPayment.errors.confirming(
        details: e.toString(),
      );
      ref.read(errorProvider.notifier).state = errorMsg;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
    // Removed extra closing brace
  }

  // _openDispute method removed as per instructions

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.maker.conflict.title),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.gavel_rounded,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              Text(
                t.maker.conflict.headline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                // Always show the main body text as Maker doesn't open dispute here anymore
                t.maker.conflict.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const CircularProgressIndicator()
              // else if (_isDisputeOpened) // This condition is removed
              //   ElevatedButton(
              //     onPressed: () => context.go('/'),
              //     child: Text(t.common.buttons.goHome),
              //   )
              else // This 'else' now corresponds to 'if (isLoading)'
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _confirmPayment(context, ref),
                      child: Text(t.maker.conflict.actions.confirmPayment),
                    ),
                    const SizedBox(height: 16),
                    // "Open Dispute" button removed
                    // const SizedBox(height: 16), // Keep or remove based on desired spacing
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(t.common.actions.cancelAndReturnHome),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
