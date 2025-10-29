import 'package:bitblik/src/services/api_service_nostr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../i18n/gen/strings.g.dart';
import '../../models/coordinator_info.dart';
import '../../models/offer.dart';
import '../../providers/providers.dart';
import '../../services/nostr_service.dart'; // Import DiscoveredCoordinator
import '../../widgets/coordinator_selector.dart'; // Import coordinator selector

class MakerAmountForm extends ConsumerStatefulWidget {
  const MakerAmountForm({super.key});

  @override
  ConsumerState<MakerAmountForm> createState() => _MakerAmountFormState();
}

class _MakerAmountFormState extends ConsumerState<MakerAmountForm> {
  final _fiatController = TextEditingController();
  final _amountFocusNode = FocusNode(); // Add FocusNode for amount input
  double? _satsEquivalent;
  double? _rate;
  String? _amountErrorText;

  String? _minFiatAmountStr;
  String? _maxFiatAmountStr;
  bool _isLoadingInitialData = true;
  String? _coordinatorInfoError;

  String? _selectedCoordinatorPubkey; // Remember selected coordinator pubkey
  CoordinatorInfo? _selectedCoordinatorInfo;

  @override
  void initState() {
    super.initState();
    _fiatController.addListener(_validateAndRecalculate);
    _loadInitialData();

    // Auto-focus the amount input field when screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _fiatController.removeListener(_validateAndRecalculate);
    _fiatController.dispose();
    _amountFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitialData = true;
      _coordinatorInfoError = null;
      _rate = null;
      _minFiatAmountStr = null;
      _maxFiatAmountStr = null;
    });

    final apiService = ref.read(apiServiceProvider);

    try {
      final rate = await apiService.getBtcPlnRate();
      if (!mounted) return;
      setState(() {
        _rate = rate;
      });

      // min/max will be set when coordinator is selected
      _validateAndRecalculate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _coordinatorInfoError = t.system.errors.loadingCoordinatorConfig;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  void _validateAndRecalculate() {
    final text = _fiatController.text;
    String? currentError;
    double? parsedFiat;
    final coordinatorInfo = _selectedCoordinatorInfo;

    if (text.isEmpty) {
      parsedFiat = null;
      currentError = null;
    } else {
      final fiatString = text.replaceAll(',', '.');
      parsedFiat = double.tryParse(fiatString);

      if (parsedFiat == null) {
        currentError = t.exchange.errors.invalidFormat;
      } else if (parsedFiat <= 0) {
        currentError = t.exchange.errors.mustBePositive;
      } else {
        if (coordinatorInfo != null && _rate != null) {
          final minAllowedFiat =
              (coordinatorInfo.minAmountSats / 100000000.0) * _rate!;
          final maxAllowedFiat =
              (coordinatorInfo.maxAmountSats / 100000000.0) * _rate!;
          final minFiat = (minAllowedFiat * 100).ceil() / 100;
          final maxFiat = maxAllowedFiat.floor().toDouble(); // Round down to nearest integer
          if (parsedFiat < minFiat) {
            currentError = t.exchange.errors.tooLowFiat(
              minAmount: minFiat.toStringAsFixed(2),
              currency: "PLN",
            );
          } else if (parsedFiat > maxFiat) {
            currentError = t.exchange.errors.tooHighFiat(
              maxAmount: maxFiat.toStringAsFixed(0),
              currency: "PLN",
            );
          } else {
            currentError = null;
          }
        }
      }
    }

    setState(() {
      _amountErrorText = currentError;
      if (currentError == null &&
          parsedFiat != null &&
          parsedFiat > 0 &&
          _rate != null) {
        final btcPerPln = 1 / _rate!;
        final btcAmount = parsedFiat * btcPerPln;
        _satsEquivalent = btcAmount * 100000000;
      } else {
        _satsEquivalent = null;
      }
    });
  }

  Future<void> _initiateOffer() async {
    final coordinatorPubkey = _selectedCoordinatorPubkey;
    if (coordinatorPubkey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a coordinator first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final publicKeyAsyncValue = ref.read(publicKeyProvider);
    final makerId = publicKeyAsyncValue.value;
    if (makerId == null) {
      ref.read(errorProvider.notifier).state =
          t.maker.amountForm.errors.publicKeyNotLoaded;
      return;
    }

    final fiatString = _fiatController.text.replaceAll(',', '.');
    final fiatAmount = double.parse(fiatString);

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.initiateOfferFiat(
        fiatAmount: fiatAmount,
        makerId: makerId,
        coordinatorPubkey: coordinatorPubkey,
      );
      ref.read(holdInvoiceProvider.notifier).state = result['holdInvoice'];
      ref.read(paymentHashProvider.notifier).state = result['paymentHash'];
      await ref
          .read(activeOfferProvider.notifier)
          .setActiveOffer(
            Offer(
              id: "empty",
              amountSats: result['makerFees'] + result['amountSats'],
              makerFees: result['makerFees'],
              status: OfferStatus.created.name,
              fiatAmount: fiatAmount,
              fiatCurrency: "PLN", // TODO
              createdAt: DateTime.now(),
              holdInvoicePaymentHash: result['paymentHash'],
              holdInvoice: result['holdInvoice'],
              makerPubkey: makerId,
              coordinatorPubkey: coordinatorPubkey,
            ),
          );
      if (mounted) {
        context.push("/pay");
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = t.maker.amountForm.errors
          .initiating(details: e.toString());
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final globalErrorMessage = ref.watch(errorProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);
    // final coordinatorInfo = _selectedCoordinatorInfo;
    final t = Translations.of(context);

    if (_isLoadingInitialData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_coordinatorInfoError != null) {
      return Center(child: Text(_coordinatorInfoError!));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (globalErrorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  globalErrorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              if (_amountErrorText == null) const SizedBox(height: 26.0),
            ],
            Text(
              t.exchange.labels.enterAmount,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              focusNode: _amountFocusNode,
              controller: _fiatController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: t.common.labels.amount,
                errorText: _amountErrorText,
              ),
            ),
            const SizedBox(height: 16),

            // Coordinator Selector
            CoordinatorSelector(
              fiatExchangeRate: _rate,
              selectedCoordinator:
                  _selectedCoordinatorPubkey != null &&
                          _selectedCoordinatorInfo != null
                      ? DiscoveredCoordinator(
                        pubkey: _selectedCoordinatorPubkey!,
                        name: _selectedCoordinatorInfo!.name,
                        icon: _selectedCoordinatorInfo!.icon,
                        version: _selectedCoordinatorInfo!.version ?? "",
                        minAmountSats: _selectedCoordinatorInfo!.minAmountSats,
                        maxAmountSats: _selectedCoordinatorInfo!.maxAmountSats,
                        makerFee: _selectedCoordinatorInfo!.makerFee,
                        takerFee: _selectedCoordinatorInfo!.takerFee,
                        currencies: _selectedCoordinatorInfo!.currencies,
                        reservationSeconds:
                            _selectedCoordinatorInfo!.reservationSeconds,
                        lastSeen:
                            DateTime.now(), // NOTE: could track lastSeen if important
                      )
                      : null,
              onCoordinatorSelected: (coordinator) async {
                setState(() {
                  _selectedCoordinatorPubkey = coordinator.pubkey;
                  _selectedCoordinatorInfo = coordinator.toCoordinatorInfo();
                });
                if (_rate != null) {
                  final minAllowedFiat =
                      (_selectedCoordinatorInfo!.minAmountSats / 100000000.0) *
                      _rate!;
                  final maxAllowedFiat =
                      (_selectedCoordinatorInfo!.maxAmountSats / 100000000.0) *
                      _rate!;
                  final minFiat = (minAllowedFiat * 100).ceil() / 100;
                  final maxFiat = maxAllowedFiat.floor(); // Round down to nearest integer
                  setState(() {
                    _minFiatAmountStr = "$minFiat";
                    _maxFiatAmountStr = "${maxFiat.toInt()}"; // Display as integer
                  });
                  _validateAndRecalculate();
                }
              },
            ),

            const SizedBox(height: 8),
            if (_rate == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  t.exchange.errors.fetchingRate,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_satsEquivalent != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  t.exchange.labels.equivalent(
                    sats: _satsEquivalent!.toStringAsFixed(0),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_rate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "${t.exchange.labels.rate(rate: _rate!.toStringAsFixed(0))}\n(${ApiServiceNostr.exchangeRateSourceNames.join(', ')})",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _selectedCoordinatorPubkey == null ||
                          isLoading ||
                          _isLoadingInitialData ||
                          publicKeyAsyncValue.isLoading ||
                          _amountErrorText != null ||
                          _fiatController.text.isEmpty ||
                          _rate == null
                      ? null
                      : () {
                        _initiateOffer();
                      },
              child:
                  isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Text(t.maker.amountForm.actions.generateInvoice),
            ),
          ],
        ),
      ),
    );
  }
}
