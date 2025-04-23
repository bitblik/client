import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';
import '../../models/offer.dart'; // For OfferStatus enum
import 'maker_success_screen.dart'; // Import the new success screen

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

  // Helper to reset state and go back to role selection
  void _resetToRoleSelection(
    BuildContext context,
    WidgetRef ref,
    String message,
  ) {
    // Cancel any active timers if they were somehow still running (unlikely here)
    // ref.read(timerProvider)?.cancel(); // Example if a timer provider existed

    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(holdInvoiceProvider.notifier).state = null;
    ref.read(paymentHashProvider.notifier).state = null;
    ref.read(receivedBlikCodeProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;

    // Use WidgetsBinding to ensure context is available if called during build/callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check mounted status before accessing context/scaffold
      if (ScaffoldMessenger.maybeOf(context) != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final paymentHash = ref.read(paymentHashProvider);
    final makerId = ref.read(publicKeyProvider).value; // Read current value

    if (paymentHash == null || makerId == null) {
      ref.read(errorProvider.notifier).state =
          'Error: Missing payment hash or public key.';
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    // Read the active offer to get its ID
    final offer = ref.read(activeOfferProvider);
    if (offer == null) {
      ref.read(errorProvider.notifier).state =
          'Error: Active offer details not found.';
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
        throw Exception(
          "Offer not in correct state for confirmation (Status: $offerStatus)",
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
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Payment Confirmed! Taker will be paid.'),
          ),
        );
      }
      // Navigate to Success Screen instead of resetting here
      if (context.mounted) {
        context.go('/maker-success',extra: offer);
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Error confirming payment: $e';
    } finally {
      // Ensure loading state is reset even if widget is disposed during async operation
      if (ref.context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: const [
              Text(
                "Retrieving BLIK code...",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
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
            mainAxisAlignment:
                MainAxisAlignment.center, // Keep centering attempt
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
              const Text(
                'BLIK Code Received!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                receivedBlikCode, // Display the received code
                style: const TextStyle(
                  fontSize: 32, // Make it larger
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3, // Add spacing
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Added style with slightly smaller font size to prevent overflow
              const Text(
                'Enter this code into the payment terminal. Once the Taker confirms in their bank app and the payment succeeds, press Confirm below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14), // Adjust font size as needed
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
                        : const Text(
                          'Confirm Payment Success',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
    );
  }
}
