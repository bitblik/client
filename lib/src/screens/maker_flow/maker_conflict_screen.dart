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
  bool _isDisputeOpened = false;
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
      await apiService.confirmMakerPayment(widget.offer.id, makerId, widget.offer.coordinatorPubkey);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(t.maker.confirmPayment.feedback.confirmedTakerPaid)),
      );
      context.go('/maker-success', extra: widget.offer);
    } catch (e) {
      final errorMsg = t.maker.confirmPayment.errors.confirming(details: e.toString());
      ref.read(errorProvider.notifier).state = errorMsg;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _openDispute(BuildContext context, WidgetRef ref) async {
    final apiService = ref.read(apiServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context); 
    final makerId = await ref.read(publicKeyProvider.future);


    if (makerId == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(t.maker.amountForm.errors.publicKeyNotLoaded)),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(t.maker.conflict.disputeDialog.title),
          content: Text(t.maker.conflict.disputeDialog.contentDetailed),
          actions: <Widget>[
            TextButton(
              child: Text(t.common.buttons.cancel),
              onPressed: () => navigator.pop(false), 
            ),
            ElevatedButton(
              child: Text(t.maker.conflict.disputeDialog.actions.confirm),
              onPressed: () => navigator.pop(true), 
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return; 
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      // Assuming openDispute is now markOfferConflict
      await apiService.markOfferConflict(widget.offer.id, makerId, widget.offer.coordinatorPubkey);

      setState(() {
        _isDisputeOpened = true; 
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(t.maker.conflict.feedback.disputeOpenedSuccess)),
      );
    } catch (e) {
      final errorMsg = t.maker.conflict.errors.openingDispute(error: e.toString());
      ref.read(errorProvider.notifier).state = errorMsg;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

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
                _isDisputeOpened
                    ? t.maker.conflict.feedback.disputeOpenedSuccess 
                    : t.maker.conflict.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const CircularProgressIndicator()
              else if (_isDisputeOpened)
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(t.common.buttons.goHome), 
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor:  Colors.white,
                      ),
                      onPressed: () => _confirmPayment(context, ref),
                      child: Text(t.maker.conflict.actions.confirmPayment),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error, 
                        foregroundColor:  Colors.white,
                      ),
                      onPressed: () => _openDispute(context, ref),
                      child: Text(t.maker.conflict.actions.openDispute),
                    ),
                    const SizedBox(height: 16),
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
