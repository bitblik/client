import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart'; // Assuming userPublicKeyProvider is here

class MakerConflictScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const MakerConflictScreen({super.key, required this.offer});

  @override
  ConsumerState<MakerConflictScreen> createState() =>
      _MakerConflictScreenState();
}

class _MakerConflictScreenState extends ConsumerState<MakerConflictScreen> {
  bool _isDisputeOpened = false;
  final _formKey = GlobalKey<FormState>();
  final _lnAddressController = TextEditingController();

  @override
  void dispose() {
    _lnAddressController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final apiService = ref.read(apiServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Read the future value of the public key provider
    final makerId = await ref.read(publicKeyProvider.future);

    if (makerId == null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.errorPublicKeyNotLoaded)),
      );
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      // Confirm payment using offerId and makerId
      await apiService.confirmMakerPayment(widget.offer.id, makerId);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.paymentConfirmedTakerPaid)),
      );
      // Navigate to success screen, passing the updated offer
      context.go('/maker-success', extra: widget.offer);
    } catch (e) {
      final errorMsg = l10n.errorConfirmingPayment(e.toString());
      ref.read(errorProvider.notifier).state = errorMsg;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
  /*
    offerAsync.when(
      data: (offer) async {
        if (offer == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.errorOfferNotFound)),
          );
          return;
        }
        final paymentHash = offer.holdInvoicePaymentHash;
        if (paymentHash == null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.errorMissingPaymentHash)),
          );
          return;
        }

        ref.read(isLoadingProvider.notifier).state = true;
        ref.read(errorProvider.notifier).state = null;

        try {
          await apiService.confirmMakerPayment(paymentHash);
          ref.read(activeOfferProvider.notifier).state = offer.copyWith(
            status: OfferStatus.makerConfirmed.name,
          ); // Update local state
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.paymentConfirmedTakerPaid)),
          );
          // Navigate to success screen, passing the updated offer
          context.go('/maker-success', extra: offer);
        } catch (e) {
          final errorMsg = l10n.errorConfirmingPayment(e.toString());
          ref.read(errorProvider.notifier).state = errorMsg;
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
        } finally {
          ref.read(isLoadingProvider.notifier).state = false;
        }
      },
      loading: () => ref.read(isLoadingProvider.notifier).state = true,
      error: (err, stack) {
        final errorMsg = l10n.errorLoadingOffer(err.toString());
        ref.read(errorProvider.notifier).state = errorMsg;
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
        ref.read(isLoadingProvider.notifier).state = false;
      },
    );
  }*/

  Future<void> _openDispute(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final apiService = ref.read(apiServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context); // For managing dialogs

    // 1. Show Confirmation Dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.makerConflictDisputeDialogTitle),
          content: Text(l10n.makerConflictDisputeDialogContentDetailed),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.makerConflictDisputeDialogCancel),
              onPressed: () => navigator.pop(false), // Dismiss with false
            ),
            ElevatedButton(
              child: Text(l10n.makerConflictDisputeDialogConfirm),
              onPressed: () => navigator.pop(true), // Dismiss with true
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return; // User cancelled
    }

    // 3. Call API to Open Dispute
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      // TODO: Define and implement apiService.openDispute in ApiService
      // For now, assume it exists and takes offerId and address
      // await apiService.openDispute(widget.offerId, lightningAddress);

      setState(() {
        _isDisputeOpened = true; // Update UI state
      });
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.successOpenDispute)),
      );
      // Optionally update local offer state if needed, though the screen changes anyway
      // ref.read(activeOfferProvider.notifier).update((state) => state?.copyWith(status: OfferStatus.dispute.name));
    } catch (e) {
      final errorMsg = l10n.errorOpenDispute(e.toString());
      ref.read(errorProvider.notifier).state = errorMsg;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.makerConflictTitle),
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
                l10n.makerConflictHeadline,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _isDisputeOpened
                    ? l10n
                        .successOpenDispute // Show success message if dispute opened
                    : l10n.makerConflictBody,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // if (!_isDisputeOpened)
              //   Text(
              //     // Show instructions only before dispute is opened
              //     l10n.makerConflictInstructions,
              //     textAlign: TextAlign.center,
              //     style: const TextStyle(fontWeight: FontWeight.bold),
              //   ),
              const SizedBox(height: 32),
              if (isLoading)
                const CircularProgressIndicator()
              else if (_isDisputeOpened)
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.goHome), // Go home after dispute
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
                      child: Text(l10n.makerConflictConfirmPaymentButton),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Make it stand out
                        foregroundColor:  Colors.white,
                      ),
                      onPressed: () => _openDispute(context, ref),
                      child: Text(l10n.makerConflictOpenDisputeButton),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      // Add a way back if they don't want to act now
                      onPressed: () => context.go('/'),
                      child: Text(l10n.cancelAndReturnHome),
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
