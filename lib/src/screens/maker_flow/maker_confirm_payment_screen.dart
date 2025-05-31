import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../i18n/gen/strings.g.dart'; // Correct Slang import
import '../../providers/providers.dart';
import '../../models/offer.dart'; // For OfferStatus enum and Offer
// import 'maker_invalid_blik_screen.dart'; // This import seems correct if the file exists at this path
import 'package:flutter/services.dart'; // Add this import for clipboard

class MakerConfirmPaymentScreen extends ConsumerStatefulWidget {
  const MakerConfirmPaymentScreen({super.key});

  @override
  ConsumerState<MakerConfirmPaymentScreen> createState() =>
      _MakerConfirmPaymentScreenState();
}

class _MakerConfirmPaymentScreenState
    extends ConsumerState<MakerConfirmPaymentScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBlikCode();
  }

  Future<void> _fetchBlikCode() async {
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;
    if (offer == null || makerId == null) return;
    final apiService = ref.read(apiServiceProvider);
    final blikCode = await apiService.getBlikCodeForMaker(offer.id, makerId);
    if (blikCode != null) {
      ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
    }
  }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final paymentHash = ref.read(paymentHashProvider);
    final makerId = ref.read(publicKeyProvider).value; // Read current value

    if (paymentHash == null || makerId == null) {
      ref.read(errorProvider.notifier).state =
          t.maker.confirmPayment.errors.missingHashOrKey; // Use Slang t
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    final offer = ref.read(activeOfferProvider);
    if (offer == null) {
      ref.read(errorProvider.notifier).state =
          t.offers.errors.detailsMissing; // Use Slang t
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    final offerId = offer.id;

    try {
      final apiService = ref.read(apiServiceProvider);
      final offerStatus = await apiService.getOfferStatus(paymentHash);
      if (offerStatus == null ||
          (offerStatus != OfferStatus.blikReceived.name &&
              offerStatus != OfferStatus.blikSentToMaker.name)) {
        throw Exception(
          t.maker.confirmPayment.errors.incorrectState(
            status: offerStatus ?? 'null',
          ), // Use Slang t
        );
      }

      print(
        "[MakerConfirmPaymentScreen] Confirming payment for offer $offerId by maker $makerId",
      );
      await apiService.confirmMakerPayment(offerId, makerId);

      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(t.maker.confirmPayment.feedback.confirmedTakerPaid),
          ), // Use Slang t
        );
      }
      if (context.mounted) {
        context.go('/maker-success', extra: offer);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = t.maker.confirmPayment.errors
          .confirming(details: e.toString()); // Use Slang t
    } finally {
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _markBlikInvalid(BuildContext context, WidgetRef ref) async {
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;

    if (offer == null || makerId == null) {
      ref.read(errorProvider.notifier).state =
          t.offers.errors.detailsMissing; // Use Slang t
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      print(
        "[MakerConfirmPaymentScreen] Marking BLIK invalid for offer ${offer.id} by maker $makerId",
      );
      await apiService.markBlikInvalid(offer.id, makerId);

      if (context.mounted) {
        context.go('/maker-invalid-blik', extra: offer);
      }
    } catch (e) {
      // TODO: Add specific localization for this error in YAML and use it here
      ref.read(errorProvider.notifier).state =
          '${t.system.errors.generic}: $e'; // Use Slang t
    } finally {
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.system.blik.copied), // Use Slang t
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final strings = AppLocalizations.of(context)!; // REMOVE THIS
    final ref =
        this.ref; // 'ref' is already available in ConsumerStatefulWidget's state
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorProvider);
    final receivedBlikCode = ref.watch(receivedBlikCodeProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);

    if (receivedBlikCode == null) {
      return Scaffold(
        // Added Scaffold wrapper
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.maker.confirmPayment.retrieving, // Use Slang t
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // Added Scaffold wrapper
      appBar: AppBar(title: Text(t.maker.confirmPayment.title)), // Use Slang t
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (errorMessage != null) ...[
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              Text(
                t.maker.confirmPayment.title, // Use Slang t
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    receivedBlikCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(receivedBlikCode),
                    tooltip: t.common.clipboard.copyToClipboard, // Use Slang t
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                t.maker.confirmPayment.instructions, // Use Slang t
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                softWrap: true,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed:
                    isLoading || publicKeyAsyncValue.isLoading
                        ? null
                        : () => _confirmPayment(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          t.maker.confirmPayment.actions.confirm, // Use Slang t
                          style: const TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed:
                    isLoading || publicKeyAsyncValue.isLoading
                        ? null
                        : () => _markBlikInvalid(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          t
                              .maker
                              .confirmPayment
                              .actions
                              .markInvalid, // Use Slang t
                          style: const TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
