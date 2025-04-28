import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

import '../../providers/providers.dart';

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
  String? _amountErrorText; // Local state for amount validation error

  @override
  void initState() {
    super.initState();
    _fiatController.addListener(_validateAndRecalculate); // Use combined method
    _fetchRate();
  }

  @override
  void dispose() {
    _fiatController.removeListener(
      _validateAndRecalculate,
    ); // Clean up listener
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
      final rate = await apiService.getBtcPlnRate();
      setState(() {
        _rate = rate;
      });
      _validateAndRecalculate(); // Update sats equivalent and validate after fetching rate
    } catch (_) {
      setState(() {
        _rate = null;
        // Optionally handle rate fetch error display
      });
    } finally {
      setState(() {
        _isFetchingRate = false;
      });
    }
  }

  // Combined validation and calculation method
  void _validateAndRecalculate() {
    // Get localizations instance - needed here for validation messages
    // Note: Accessing context here might be tricky if called before build.
    // A safer approach might be to pass `strings` from `build` or store it.
    // For simplicity now, we'll assume context is available or handle potential null later.
    final strings = AppLocalizations.of(context);
    if (strings == null) return; // Early exit if context/strings not ready

    final text = _fiatController.text;
    String? currentError; // Temporary error variable for this validation run
    double? parsedFiat;

    if (text.isEmpty) {
      // Allow empty field initially, but clear sats
      parsedFiat = null;
      currentError = null; // No error if empty
    } else {
      // Replace comma with dot for parsing
      final fiatString = text.replaceAll(',', '.');
      parsedFiat = double.tryParse(fiatString);

      if (parsedFiat == null) {
        currentError = strings.errorInvalidNumberFormat; // Use localized string
      } else if (parsedFiat <= 0) {
        currentError =
            strings.errorAmountMustBePositive; // Use localized string
      } else {
        currentError = null; // Valid number
      }
    }

    // Update state: error text and sats equivalent
    setState(() {
      _amountErrorText = currentError; // Update local error state

      if (parsedFiat != null && parsedFiat > 0 && _rate != null) {
        final btcPerPln = 1 / _rate!;
        final btcAmount = parsedFiat * btcPerPln;
        _satsEquivalent = btcAmount * 100000000;
      } else {
        _satsEquivalent = null; // Clear sats if input is invalid or empty
      }
    });
  }

  Future<void> _initiateOffer() async {
    final strings = AppLocalizations.of(context)!; // Get localizations

    // Re-validate on submit just in case, and check fee
    _validateAndRecalculate(); // Ensure latest state is validated
    final fee = int.tryParse(
      _feeController.text,
    ); // Keep fee validation simple for now

    // Check local error state and fee validity
    if (_amountErrorText != null ||
        _fiatController.text.isEmpty ||
        fee == null ||
        fee < 0) {
      // Optionally set a general error if fee is invalid, or handle fee validation live too
      if (fee == null || fee < 0) {
        // Use localized string for fee error
        ref.read(errorProvider.notifier).state =
            strings.errorInvalidFeePercentage;
      } else if (_amountErrorText != null || _fiatController.text.isEmpty) {
        // Error already shown by the TextField, just prevent submission
        print("Submission prevented due to amount error: $_amountErrorText");
      }
      return; // Prevent submission if there's an error or field is empty
    }

    // Proceed only if validation passed (_amountErrorText is null and field not empty)
    final publicKeyAsyncValue = ref.read(publicKeyProvider);
    final makerId = publicKeyAsyncValue.value;
    if (makerId == null) {
      // Use localized string for public key error
      ref.read(errorProvider.notifier).state = strings.errorPublicKeyNotLoaded;
      return;
    }

    // We know parsing works because validation passed
    final fiatString = _fiatController.text.replaceAll(',', '.');
    final fiatAmount = double.parse(
      fiatString,
    ); // Use parse() as tryParse succeeded

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null; // Clear global API errors

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.initiateOfferFiat(
        fiatAmount: fiatAmount,
        feePercentage: fee, // Already parsed and checked fee
        makerId: makerId,
      );
      ref.read(holdInvoiceProvider.notifier).state = result['holdInvoice'];
      ref.read(paymentHashProvider.notifier).state = result['paymentHash'];

      if (mounted) {
        context.go("/pay");
      }
    } catch (e) {
      // Use localized string for initiation error
      ref.read(errorProvider.notifier).state = strings.errorInitiatingOffer(
        e.toString(),
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!; // Get localizations
    final isLoading = ref.watch(isLoadingProvider);
    // Keep global error for API/other errors, but amount error is local
    final globalErrorMessage = ref.watch(errorProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display global error message if it exists
            if (globalErrorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  globalErrorMessage, // Already localized if set via provider
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              // Reserve space only if local error isn't showing
              if (_amountErrorText == null)
                const SizedBox(height: 26.0), // Adjust height as needed
            ],
            Text(
              strings.enterAmountToPay, // Use localized string
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fiatController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                // Input formatters can be added here for stricter validation if needed
              ],
              // Use local error state for TextField decoration
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: strings.amountLabel, // Use localized string
                errorText:
                    _amountErrorText, // Already localized from _validateAndRecalculate
              ),
              // No need for onChanged here anymore as listener handles it
            ),
            const SizedBox(height: 10),
            // Keep fee input simple for now
            // TextField(
            //   controller: _feeController,
            //   keyboardType: TextInputType.number,
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'Fee (%)', // TODO: Localize if fee input is re-enabled
            //   ),
            // ),
            // const SizedBox(height: 10),
            if (_isFetchingRate)
              Text(
                strings.fetchingExchangeRate, // Use localized string
                textAlign: TextAlign.center,
              )
            else if (_satsEquivalent != null)
              Text(
                // Use localized string with placeholder
                strings.satsEquivalent(_satsEquivalent!.toStringAsFixed(0)),
                style: const TextStyle(fontSize: 16, color: Colors.blue),
                textAlign: TextAlign.center,
              )
            else if (_rate != null) // Show rate only if fetched
              Text(
                // Use localized string with placeholder
                strings.plnBtcRate(_rate!.toStringAsFixed(0)),
                textAlign: TextAlign.center,
              )
            else // Placeholder or message if rate fetch failed
              Text(
                strings.errorFetchingRate, // Use localized string
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              // Disable button if loading, key missing, OR amount has error/is empty
              onPressed:
                  isLoading ||
                          publicKeyAsyncValue.isLoading ||
                          _amountErrorText != null ||
                          _fiatController.text.isEmpty
                      ? null
                      : _initiateOffer,
              child:
                  isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      // Use localized string for button text
                      : Text(strings.generateInvoice),
            ),
          ],
        ),
      ),
    );
  }
}
