import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart'; // For OfferStatus enum
import '../../services/sound_service.dart'; // Import SoundService
// Import the new success screen
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

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
    // Play sound once after the first frame when BLIK code is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if still mounted
        ref.read(soundServiceProvider).playSound("blikReceived");
      }
    });
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
    final strings = AppLocalizations.of(context)!; // Get strings instance
    final paymentHash = ref.read(paymentHashProvider);
    final makerId = ref.read(publicKeyProvider).value; // Read current value

    if (paymentHash == null || makerId == null) {
      // Use localized string
      ref.read(errorProvider.notifier).state =
          strings.errorMissingPaymentHashOrKey;
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    // Read the active offer to get its ID
    final offer = ref.read(activeOfferProvider);
    if (offer == null) {
      // Use localized string (reusing existing one)
      ref.read(errorProvider.notifier).state = strings.errorOfferDetailsMissing;
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    final offerId = offer.id; // Get the offer ID

    try {
      final apiService = ref.read(apiServiceProvider);
      // Check status using paymentHash (as before)
      final offerStatus = await apiService.getOfferStatus(paymentHash);
      if (offerStatus == null ||
          (offerStatus != OfferStatus.blikReceived.name &&
              offerStatus != OfferStatus.blikSentToMaker.name)) {
        // Use localized string with placeholder
        throw Exception(
          strings.errorOfferIncorrectStateConfirmation(offerStatus ?? 'null'),
        );
      }

      print(
        "[MakerConfirmPaymentScreen] Confirming payment for offer $offerId by maker $makerId",
      );
      // Uncommented and using offerId
      await apiService.confirmMakerPayment(offerId, makerId);

      // Use context safely
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
      if (scaffoldMessenger != null) {
        // Use localized string
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(strings.paymentConfirmedTakerPaid)),
        );
      }
      // Navigate to Success Screen instead of resetting here
      if (context.mounted) {
        context.go('/maker-success', extra: offer);
      }
    } catch (e) {
      // Use localized string with placeholder
      ref.read(errorProvider.notifier).state = strings.errorConfirmingPayment(
        e.toString(),
      );
    } finally {
      // Ensure loading state is reset even if widget is disposed during async operation
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    final strings = AppLocalizations.of(context)!; // Get strings instance
    // Use localized string
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.blikCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!; // Get strings instance
    final ref = this.ref;
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorProvider);
    final receivedBlikCode = ref.watch(receivedBlikCodeProvider);
    final publicKeyAsyncValue = ref.watch(
      publicKeyProvider,
    ); // Watch for disabling button

    // Handle case where BLIK code is somehow null when reaching this screen
    if (receivedBlikCode == null) {
      // Show info and progress indicator in the Scaffold
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use localized string
            Text(
              strings.retrievingBlikCode,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      );
    }

    // Wrap the Padding with Scaffold and SingleChildScrollView
    return SingleChildScrollView(
      // Added SingleChildScrollView
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Keep centering attempt
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display Error Messages
            if (errorMessage != null) ...[
              Text(
                errorMessage,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
            // Use localized string
            Text(
              strings.blikCodeReceivedTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  // Use localized string
                  tooltip: strings.copyToClipboardTooltip,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Added style with slightly smaller font size to prevent overflow
            // Use localized string
            Text(
              strings.blikInstructionsMaker,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
              ), // Adjust font size as needed
              softWrap: true, // Ensure text wraps
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
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ), // Make button larger
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        // Consistent loading indicator size
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      // Use localized string
                      : Text(
                        strings.confirmPaymentSuccessButton,
                        style: const TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
