import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart'; // To call initiateOffer
// Import the next screens
import 'maker_pay_invoice_screen.dart';
import 'maker_wait_taker_screen.dart'; // Contains MakerWaitTakerScreen now
import 'maker_confirm_payment_screen.dart';
import '../../models/offer.dart'; // Import Offer model for AppRole enum

class MakerAmountForm extends ConsumerStatefulWidget {
  const MakerAmountForm({super.key});

  @override
  ConsumerState<MakerAmountForm> createState() => _MakerAmountFormState();
}

class _MakerAmountFormState extends ConsumerState<MakerAmountForm> {
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '1'); // Default fee 1%

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  // Helper to reset state and go back to role selection
  void _resetToRoleSelection(String message) {
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(holdInvoiceProvider.notifier).state = null;
    ref.read(paymentHashProvider.notifier).state = null;
    ref.read(receivedBlikCodeProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  Future<void> _initiateOffer() async {
    final publicKeyAsyncValue = ref.read(publicKeyProvider);
    final makerId = publicKeyAsyncValue.value;

    if (makerId == null) {
      ref.read(errorProvider.notifier).state =
          'Error: Public key not loaded yet.';
      return;
    }
    final amount = int.tryParse(_amountController.text);
    final fee = int.tryParse(_feeController.text);

    if (amount == null || amount <= 0 || fee == null || fee < 0) {
      ref.read(errorProvider.notifier).state =
          'Please enter a valid amount and fee percentage.';
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.initiateOffer(
        amountSats: amount,
        feePercentage: fee,
        makerId: makerId,
      );
      ref.read(holdInvoiceProvider.notifier).state = result['holdInvoice'];
      ref.read(paymentHashProvider.notifier).state = result['paymentHash'];

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => MakerPayInvoiceScreen(
                  onPaymentConfirmed: () {
                    // Navigate to MakerWaitTakerScreen after payment confirmation
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const MakerWaitTakerScreen(), // Corrected navigation
                      ),
                    );
                  },
                ),
          ),
        );
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Error initiating offer: $e';
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Offer: Amount"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Role Selection',
          onPressed: () => _resetToRoleSelection("Offer creation cancelled."),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () => _resetToRoleSelection("Offer creation cancelled."),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              const Text(
                'Enter Amount (sats) to Pay:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount (sats)',
                ),
              ),
              // const SizedBox(height: 10),
              // const Text('Premium Fee (%):', style: TextStyle(fontSize: 16)),
              // const SizedBox(height: 8),
              // TextField(
              //   controller: _feeController,
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Fee % (e.g., 1)',
              //   ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isLoading || publicKeyAsyncValue.isLoading
                        ? null
                        : _initiateOffer,
                child:
                    isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text('Generate Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
