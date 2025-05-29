import 'package:bitblik/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart';

class MakerAmountForm extends ConsumerStatefulWidget {
  const MakerAmountForm({super.key});

  @override
  ConsumerState<MakerAmountForm> createState() => _MakerAmountFormState();
}

class _MakerAmountFormState extends ConsumerState<MakerAmountForm> {
  final _fiatController = TextEditingController();
  double? _satsEquivalent;
  double? _rate;
  String? _amountErrorText;

  String? _minFiatAmountStr;
  String? _maxFiatAmountStr;
  bool _isLoadingInitialData = true;
  String? _coordinatorInfoError;

  @override
  void initState() {
    super.initState();
    _fiatController.addListener(_validateAndRecalculate);
    _loadInitialData();
  }

  @override
  void dispose() {
    _fiatController.removeListener(_validateAndRecalculate);
    _fiatController.dispose();
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

      // Try to get coordinator info and set min/max fiat immediately if possible
      final coordinatorInfoAsync = ref.read(coordinatorInfoProvider);
      final coordinatorInfo = coordinatorInfoAsync.asData?.value;
      if (coordinatorInfo != null) {
        final minAllowedFiat =
            (coordinatorInfo.minAmountSats / 100000000.0) * rate;
        final maxAllowedFiat =
            (coordinatorInfo.maxAmountSats / 100000000.0) * rate;
        final minFiat = (minAllowedFiat * 100).ceil() / 100;
        final maxFiat = (maxAllowedFiat * 100).floor() / 100;
        _minFiatAmountStr = "$minFiat";
        _maxFiatAmountStr = "$maxFiat";
      }

      _validateAndRecalculate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final strings = AppLocalizations.of(context);
        if (strings != null) {
          _coordinatorInfoError = strings.errorLoadingCoordinatorConfig;
        } else {
          _coordinatorInfoError = "Error loading configuration.";
        }
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  void _validateAndRecalculate() {
    final strings = AppLocalizations.of(context);
    if (strings == null) return;

    final coordinatorInfoAsync = ref.read(coordinatorInfoProvider);
    final coordinatorInfo = coordinatorInfoAsync.asData?.value;
    final text = _fiatController.text;
    String? currentError;
    double? parsedFiat;

    if (text.isEmpty) {
      parsedFiat = null;
      currentError = null;
    } else {
      final fiatString = text.replaceAll(',', '.');
      parsedFiat = double.tryParse(fiatString);

      if (parsedFiat == null) {
        currentError = strings.errorInvalidNumberFormat;
      } else if (parsedFiat <= 0) {
        currentError = strings.errorAmountMustBePositive;
      } else {
        if (coordinatorInfo != null && _rate != null) {
          final minAllowedFiat =
              (coordinatorInfo.minAmountSats / 100000000.0) * _rate!;
          final maxAllowedFiat =
              (coordinatorInfo.maxAmountSats / 100000000.0) * _rate!;
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
            currentError = null;
          }
          // Do not overwrite _minFiatAmountStr/_maxFiatAmountStr here
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
    final strings = AppLocalizations.of(context)!;
    final coordinatorInfoAsync = ref.read(coordinatorInfoProvider);
    final coordinatorInfo = coordinatorInfoAsync.asData?.value;

    if (coordinatorInfo == null || _rate == null) {
      ref.read(errorProvider.notifier).state =
          strings.errorLoadingCoordinatorConfig;
      print("Attempted to initiate offer without coordinator info or rate.");
      return;
    }

    _validateAndRecalculate();

    final publicKeyAsyncValue = ref.read(publicKeyProvider);
    final makerId = publicKeyAsyncValue.value;
    if (makerId == null) {
      ref.read(errorProvider.notifier).state = strings.errorPublicKeyNotLoaded;
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
      );
      ref.read(holdInvoiceProvider.notifier).state = result['holdInvoice'];
      ref.read(paymentHashProvider.notifier).state = result['paymentHash'];
      ref.read(activeOfferProvider.notifier).state = Offer(
        id: "empty",
        amountSats: result['makerFees'] + result['amountSats'],
        makerFees: result['makerFees'],
        status: OfferStatus.created.name,
        fiatAmount: fiatAmount,
        fiatCurrency: "PLN", // TODO
        createdAt: DateTime.now(),
        makerPubkey: makerId,
      );
      if (mounted) {
        context.go("/pay");
      }
    } catch (e) {
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
    final strings = AppLocalizations.of(context)!;
    final isLoading = ref.watch(isLoadingProvider);
    final globalErrorMessage = ref.watch(errorProvider);
    final publicKeyAsyncValue = ref.watch(publicKeyProvider);
    final coordinatorInfoAsync = ref.watch(coordinatorInfoProvider);

    final coordinatorInfo = coordinatorInfoAsync.asData?.value;

    if (_isLoadingInitialData || coordinatorInfoAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (coordinatorInfoAsync.hasError) {
      return Center(
        child: Text(
          "${coordinatorInfo?.makerFee != null ? coordinatorInfo!.makerFee.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '') : '0'}% fee",
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
        ),
      );
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
              strings.enterAmountToPay,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fiatController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: strings.amountLabel,
                errorText: _amountErrorText,
              ),
            ),
            const SizedBox(height: 10),
            if (coordinatorInfo != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: InkWell(
                  onTap: () async {
                    final npub = coordinatorInfo.nostrNpub;
                    if (npub != null && npub.isNotEmpty) {
                      final url = 'https://njump.me/$npub';
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (coordinatorInfo.icon != null &&
                          coordinatorInfo.icon!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child:
                              coordinatorInfo.icon!.startsWith('http')
                                  ? Image.network(
                                    coordinatorInfo.icon!,
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
                                    coordinatorInfo.icon!,
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
                      Text(
                        coordinatorInfo.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (coordinatorInfo.version != null &&
                          coordinatorInfo.version!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            'v${coordinatorInfo.version!}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ),

                      if (_minFiatAmountStr != null &&
                          _maxFiatAmountStr != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Row(
                            children: [
                              Text(
                                strings.amountRangeHint(
                                  _minFiatAmountStr!,
                                  _maxFiatAmountStr!,
                                  "PLN",
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${coordinatorInfo.makerFee.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')}% fee",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.blueGrey),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (_rate == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  strings.errorFetchingRate,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_satsEquivalent != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  strings.satsEquivalent(_satsEquivalent!.toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              )
            else if (_rate != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Coingecko ${strings.plnBtcRate(_rate!.toStringAsFixed(0))}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              const SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (isLoading ||
                          _isLoadingInitialData ||
                          publicKeyAsyncValue.isLoading ||
                          _amountErrorText != null ||
                          _fiatController.text.isEmpty ||
                          coordinatorInfo == null ||
                          _rate == null)
                      ? null
                      : _initiateOffer,
              child:
                  isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Text(strings.generateInvoice),
            ),
          ],
        ),
      ),
    );
  }
}
