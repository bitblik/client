import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import localization

import '../../models/coordinator_info.dart'; // Added
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
  // bool _isFetchingRate = false; // Replaced by _isLoadingInitialData
  String? _amountErrorText; // Local state for amount validation error

  // New state variables for CoordinatorInfo and fiat limits
  CoordinatorInfo? _coordinatorInfo;
  String? _minFiatAmountStr;
  String? _maxFiatAmountStr;
  bool _isLoadingInitialData = true; // Combined loading state
  String? _coordinatorInfoError; // Error for coordinator info loading

  @override
  void initState() {
    super.initState();
    _fiatController.addListener(_validateAndRecalculate);
    _loadInitialData(); // New method to load coordinator info and rate
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

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitialData = true;
      _coordinatorInfoError = null;
      _rate = null; // Reset rate
      _coordinatorInfo = null; // Reset coordinator info
      _minFiatAmountStr = null;
      _maxFiatAmountStr = null;
    });

    final apiService = ref.read(apiServiceProvider);
    // AppLocalizations.of(context) can be null if context is not ready.
    // It's safer to get strings inside build or pass it if needed here.
    // For now, we'll assume it might be an issue if called too early.
    // However, for setting _coordinatorInfoError, we need it.
    // A better pattern might be to set a generic error and let build() localize it.

    try {
      // Fetch CoordinatorInfo and Rate in parallel
      final results = await Future.wait([
        apiService.getCoordinatorInfo(),
        apiService.getBtcPlnRate(),
      ]);

      final coordinatorInfo = results[0] as CoordinatorInfo;
      final rate = results[1] as double;

      if (!mounted) return;

      setState(() {
        _coordinatorInfo = coordinatorInfo;
        _rate = rate;

        if (_coordinatorInfo != null && _rate != null) {
          final minFiat =
              (_coordinatorInfo!.minAmountSats / 100000000.0) * _rate!;
          final maxFiat =
              (_coordinatorInfo!.maxAmountSats / 100000000.0) * _rate!;
          _minFiatAmountStr = "${(minFiat * 100).ceil() / 100}";
          _maxFiatAmountStr = "${(maxFiat * 100).floor() / 100}";
        }
      });
      _validateAndRecalculate(); // Update sats equivalent and validate
    } catch (e) {
      if (!mounted) return;
      print("Error loading initial data: $e");
      setState(() {
        // Attempt to get strings for error message
        final strings = AppLocalizations.of(context);
        if (strings != null) {
          _coordinatorInfoError = strings.errorLoadingCoordinatorConfig;
        } else {
          // Fallback if strings not available (e.g. context issue)
          _coordinatorInfoError = "Error loading configuration.";
        }
        // _rate will be null if its fetch failed, UI already handles this for rate display
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingInitialData = false;
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
        // Min/Max validation using CoordinatorInfo
        if (_coordinatorInfo != null && _rate != null) {
          final minAllowedFiat =
              (_coordinatorInfo!.minAmountSats / 100000000.0) * _rate!;
          final maxAllowedFiat =
              (_coordinatorInfo!.maxAmountSats / 100000000.0) * _rate!;
          final minFiat = (minAllowedFiat * 100).ceil() / 100;
          final maxFiat = (maxAllowedFiat * 100).floor() / 100;
          if (parsedFiat < minFiat) {
            currentError = strings.errorAmountTooLowFiat(
              minFiat.toStringAsFixed(2),
              "PLN",
            );
          } else if (parsedFiat > maxFiat) {
            currentError = strings.errorAmountTooHighFiat(
              maxFiat.toStringAsFixed(2),
              "PLN",
            );
          } else {
            currentError = null; // Valid number within range
          }
        } else {
          // Config not loaded, cannot perform min/max validation.
          // Button should be disabled, but as a fallback, don't clear other errors.
          // Or, set a specific error like "Configuration not loaded, cannot validate range."
          // For now, if currentError is null, keep it null. If it has format error, keep that.
          // This scenario should ideally be prevented by UI (disabled button).
        }
      }
    }

    // Update state: error text and sats equivalent
    setState(() {
      _amountErrorText = currentError; // Update local error state

      // Calculate sats equivalent only if there are no errors and rate is available
      if (currentError == null &&
          parsedFiat != null &&
          parsedFiat > 0 &&
          _rate != null) {
        final btcPerPln = 1 / _rate!;
        final btcAmount = parsedFiat * btcPerPln;
        _satsEquivalent = btcAmount * 100000000;
      } else {
        _satsEquivalent =
            null; // Clear sats if input is invalid, empty, or error exists
      }
    });
  }

  Future<void> _initiateOffer() async {
    final strings = AppLocalizations.of(context)!; // Get localizations

    // Safeguard: Ensure coordinator info and rate are loaded.
    // The button should be disabled if these are null, but this is an extra check.
    if (_coordinatorInfo == null || _rate == null) {
      ref.read(errorProvider.notifier).state =
          strings.errorLoadingCoordinatorConfig;
      // Optionally, could also set _coordinatorInfoError to re-trigger UI update if needed,
      // but button disabling should primarily handle this.
      print("Attempted to initiate offer without coordinator info or rate.");
      return;
    }

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

    // Early exit with loading indicator if initial data is loading
    if (_isLoadingInitialData) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display coordinator info error if it exists
            if (_coordinatorInfoError != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _coordinatorInfoError!, // Already localized from _loadInitialData
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ] // Display global API error message if it exists and no coordinator error
            else if (globalErrorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  globalErrorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              // Reserve space only if local amount error isn't showing
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
            // Display coordinator icon, name, version, and amount range in one line if available
            if (_minFiatAmountStr != null &&
                _maxFiatAmountStr != null &&
                _coordinatorInfo != null &&
                _coordinatorInfoError == null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Coordinator icon (network or asset)
                    if (_coordinatorInfo!.icon != null &&
                        _coordinatorInfo!.icon!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child:
                            _coordinatorInfo!.icon!.startsWith('http')
                                ? Image.network(
                                  _coordinatorInfo!.icon!,
                                  width: 20,
                                  height: 20,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.account_circle,
                                            size: 20,
                                          ),
                                )
                                : Image.asset(
                                  _coordinatorInfo!.icon!,
                                  width: 20,
                                  height: 20,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(
                                            Icons.account_circle,
                                            size: 20,
                                          ),
                                ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(right: 6.0),
                        child: Icon(Icons.account_circle, size: 20),
                      ),
                    // Coordinator name
                    Text(
                      _coordinatorInfo!.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    // Version (if available)
                    if (_coordinatorInfo!.version != null &&
                        _coordinatorInfo!.version!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          'v${_coordinatorInfo!.version!}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                    // Min/max amount
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        strings.amountRangeHint(
                          _minFiatAmountStr!,
                          _maxFiatAmountStr!,
                          "PLN",
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
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
            // Rate and Sats Equivalent Display Logic
            // If _isLoadingInitialData is true, this part is skipped by the loading indicator at the top of build.
            // So, we only consider cases where initial loading is done.
            if (_rate == null &&
                _coordinatorInfoError ==
                    null) // Rate fetch specifically failed or not yet loaded, and no major coord error
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  strings.errorFetchingRate,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_satsEquivalent != null) // Sats equivalent is available
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  strings.satsEquivalent(_satsEquivalent!.toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_rate !=
                null) // Sats equivalent is null (e.g. invalid input), but rate is available
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  strings.plnBtcRate(_rate!.toStringAsFixed(0)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ), // Show rate more subtly if no sats
                ),
              )
            // If _coordinatorInfoError is present, specific rate/sats info might be less relevant or confusing
            else if (_coordinatorInfoError ==
                null) // Fallback if none of the above (should be rare)
              const SizedBox(
                height: 20,
              ), // Placeholder to maintain some spacing

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (isLoading || // API call in progress
                          _isLoadingInitialData || // Initial data still loading
                          publicKeyAsyncValue.isLoading || // Public key loading
                          _amountErrorText !=
                              null || // Validation error on amount
                          _fiatController.text.isEmpty || // Amount field empty
                          _coordinatorInfo ==
                              null || // Coordinator config not loaded
                          _rate == null || // Rate not loaded
                          _coordinatorInfoError !=
                              null) // Error loading coordinator config
                      ? null // Disable button
                      : _initiateOffer, // Enable button
              child:
                  isLoading // Refers to API call in progress for _initiateOffer
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Text(strings.generateInvoice),
            ),
          ],
        ),
      ),
    );
  }
}
