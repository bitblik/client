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
  final _fiatController = TextEditingController();
  final _feeController = TextEditingController(text: '1'); // Default fee 1%
  double? _satsEquivalent;
  double? _rate;
  bool _isFetchingRate = false;

  @override
  void initState() {
    super.initState();
    _fiatController.addListener(_onFiatChanged);
    _fetchRate();
  }

  @override
  void dispose() {
    _fiatController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _fetchRate() async {
    setState(() {
      _isFetchingRate = true;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      // Use the offer API to get the rate (simulate with a dummy offer, or add a dedicated endpoint)
      final result = await apiService.initiateOfferFiatPreview();
      setState(() {
        _rate = result['rate']?.toDouble();
      });
      _onFiatChanged();
    } catch (_) {
      setState(() {
        _rate = null;
      });
    } finally {
      setState(() {
        _isFetchingRate = false;
      });
    }
  }

  void _onFiatChanged() {
    final fiat = double.tryParse(_fiatController.text);
    if (fiat != null && _rate != null) {
      final btcPerPln = 1 / _rate!;
      final btcAmount = fiat * btcPerPln;
      final sats = btcAmount * 100000000;
      setState(() {
        _satsEquivalent = sats;
      });
    } else {
      setState(() {
        _satsEquivalent = null;
      });
    }
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
    final fiatAmount = double.tryParse(_fiatController.text);
    final fee = int.tryParse(_feeController.text);

    if (fiatAmount == null || fiatAmount <= 0 || fee == null || fee < 0) {
      ref.read(errorProvider.notifier).state =
          'Please enter a valid PLN amount and fee percentage.';
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.initiateOfferFiat(
        fiatAmount: fiatAmount,
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
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MakerWaitTakerScreen(),
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

    return Padding(
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
                'Enter Amount (PLN) to Pay:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fiatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Amount (PLN)',
                ),
              ),
              const SizedBox(height: 10),
              if (_isFetchingRate)
                const Text(
                  'Fetching exchange rate from coingecko API',
                  textAlign: TextAlign.center,
                )
              else if (_satsEquivalent != null)
                Text(
                  '≈ ${_satsEquivalent!.toStringAsFixed(0)} sats',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'PLN/BTC rate (coingecko API) = ${_rate?.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                ),
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
    );
  }
}
