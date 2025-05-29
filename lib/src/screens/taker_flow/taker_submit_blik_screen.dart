import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bitblik/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../models/coordinator_info.dart'; // Added
import '../../providers/providers.dart';
import '../../services/key_service.dart'; // For LN Address prompt
import '../../services/api_service.dart'; // Added

// --- BlikInputProgressIndicator Widget ---
class BlikInputProgressIndicator extends StatefulWidget {
  final DateTime reservedAt;
  final Duration maxDuration;

  const BlikInputProgressIndicator({
    super.key,
    required this.reservedAt,
    required this.maxDuration,
  });

  @override
  State<BlikInputProgressIndicator> createState() =>
      _BlikInputProgressIndicatorState();
}

class _BlikInputProgressIndicatorState
    extends State<BlikInputProgressIndicator> {
  Timer? _timer;
  double _progress = 1.0;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.maxDuration.inSeconds;
    _calculateProgress();
    if (_progress > 0) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant BlikInputProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reservedAt != oldWidget.reservedAt) {
      print("[BlikInputProgress] reservedAt changed. Recalculating.");
      _timer?.cancel();
      _calculateProgress();
      if (_progress > 0) _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateProgress() {
    final now = DateTime.now();
    final expiresAt = widget.reservedAt.add(widget.maxDuration);
    final totalDuration = widget.maxDuration.inMilliseconds;
    final remainingDuration = expiresAt.difference(now).inMilliseconds;

    if (!mounted) return;

    setState(() {
      if (remainingDuration <= 0) {
        _progress = 0.0;
        _remainingSeconds = 0;
      } else {
        _progress = remainingDuration / totalDuration;
        _remainingSeconds = (remainingDuration / 1000).ceil().clamp(
          0,
          widget.maxDuration.inSeconds,
        );
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (_progress <= 0) return;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _calculateProgress();
      if (_progress <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_progress <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[500],
            valueColor: AlwaysStoppedAnimation<Color>(
              _remainingSeconds <= 5 ? Colors.red : Colors.green,
            ),
            minHeight: 20,
          ),
          // Use localized string with placeholder
          Text(
            AppLocalizations.of(
              context,
            )!.submitBlikWithinSeconds(_remainingSeconds),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Main Screen Widget ---

class TakerSubmitBlikScreen extends ConsumerStatefulWidget {
  final Offer initialOffer; // Initial offer data (might be incomplete)

  const TakerSubmitBlikScreen({required this.initialOffer, super.key});

  @override
  ConsumerState<TakerSubmitBlikScreen> createState() =>
      _TakerSubmitBlikScreenState();
}

class _TakerSubmitBlikScreenState extends ConsumerState<TakerSubmitBlikScreen> {
  final _blikController = TextEditingController();
  Timer? _blikInputTimer;
  // Duration _maxBlikInputTime = const Duration(seconds: 20); // Will be set from coordinatorInfo
  Duration? _maxBlikInputTime; // Will be set from coordinatorInfo
  bool _isLoadingDetails = true; // Flag for initial loading
  CoordinatorInfo? _coordinatorInfo; // Added

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchFullOfferDetails();
      }
    });
  }

  Future<void> _fetchFullOfferDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDetails = true;
    });
    ref.read(errorProvider.notifier).state = null;

    try {
      final strings = AppLocalizations.of(context)!;
      final apiService = ref.read(apiServiceProvider);

      // Fetch CoordinatorInfo first
      try {
        _coordinatorInfo = await apiService.getCoordinatorInfo();
        if (_coordinatorInfo != null) {
          _maxBlikInputTime = Duration(
            seconds: _coordinatorInfo!.reservationSeconds,
          );
        } else {
          // Fallback if coordinator info is somehow null, though getCoordinatorInfo should throw
          _maxBlikInputTime = const Duration(seconds: 20); // Default fallback
          print(
            "[TakerSubmitBlikScreen] Warning: CoordinatorInfo was null, using default timeout.",
          );
        }
      } catch (e) {
        print(
          "[TakerSubmitBlikScreen] Error fetching coordinator info: $e. Using default timeout.",
        );
        _maxBlikInputTime = const Duration(
          seconds: 20,
        ); // Default fallback on error
        // Optionally, show a non-fatal error to the user or log more verbosely
      }

      final publicKey = ref.read(publicKeyProvider).value;
      if (publicKey == null) {
        throw Exception(strings.errorPublicKeyNotLoaded);
      }

      final fullOfferData = await apiService.getMyActiveOffer(publicKey);

      if (!mounted) return;

      if (fullOfferData == null) {
        throw Exception(strings.errorCouldNotFetchActiveOffer);
      }

      final fullOffer = Offer.fromJson(fullOfferData);

      // Verify the fetched offer ID matches the initial one
      if (fullOffer.id != widget.initialOffer.id) {
        // Use localized string with placeholders
        throw Exception(
          strings.errorFetchedOfferIdMismatch(
            fullOffer.id,
            widget.initialOffer.id,
          ),
        );
      }
      // --- Validation ---
      if (fullOffer.status != OfferStatus.reserved.name) {
        // Use localized string with placeholder
        throw Exception(strings.errorOfferNotReserved(fullOffer.status));
      }
      if (fullOffer.reservedAt == null) {
        // Use localized string
        throw Exception(strings.errorOfferReservationTimestampMissing);
      }
      if (fullOffer.holdInvoicePaymentHash == null) {
        // Use localized string
        throw Exception(strings.errorOfferPaymentHashMissing);
      }
      // --- End Validation ---

      ref.read(activeOfferProvider.notifier).state = fullOffer;
      print("[TakerSubmitBlikScreen] Successfully fetched full offer details.");

      // Ensure _maxBlikInputTime is set before starting timer
      if (_maxBlikInputTime == null) {
        print(
          "[TakerSubmitBlikScreen] _maxBlikInputTime is null before _startBlikInputTimer. This should not happen.",
        );
        _maxBlikInputTime = Duration(
          seconds: _coordinatorInfo?.reservationSeconds ?? 20,
        );
      }
      _startBlikInputTimer(fullOffer);
      setState(() {
        _isLoadingDetails = false;
      });
    } catch (e) {
      print("[TakerSubmitBlikScreen] Error fetching full offer details: $e");
      if (mounted) {
        // Use localized string with placeholder
        final strings = AppLocalizations.of(context)!;
        _resetToOfferList(strings.errorLoadingOfferDetails(e.toString()));
      }
    }
  }

  @override
  void dispose() {
    _blikInputTimer?.cancel();
    _blikController.dispose();
    super.dispose();
  }

  void _startBlikInputTimer(Offer offer) {
    if (_blikInputTimer?.isActive ?? false) return;
    _blikInputTimer?.cancel();
    if (!mounted) return;

    final reservedAt = offer.reservedAt;
    if (reservedAt == null) {
      print(
        "[TakerSubmitBlikScreen] Error: reservedAt is null when starting timer. Resetting.",
      );
      // Reuse existing key
      final strings = AppLocalizations.of(context)!;
      _resetToOfferList(strings.errorOfferDetailsMissing);
      return;
    }

    final now = DateTime.now();
    // Ensure _maxBlikInputTime is non-null before proceeding
    if (_maxBlikInputTime == null) {
      print(
        "[TakerSubmitBlikScreen] Error: _maxBlikInputTime is null in _startBlikInputTimer. Resetting.",
      );
      final strings = AppLocalizations.of(context)!;
      _resetToOfferList(
        "${strings.errorOfferDetailsMissing} (Timeout config)",
      ); // Append context
      return;
    }

    final expiresAt = reservedAt.add(
      _maxBlikInputTime!,
    ); // Use non-null assertion
    final timeUntilExpiry = expiresAt.difference(now);

    print(
      "[TakerSubmitBlikScreen] Starting BLIK input timeout timer for ${_maxBlikInputTime!.inSeconds}s. Expires ~ $expiresAt",
    );

    if (timeUntilExpiry.isNegative) {
      _handleBlikInputTimeout();
    } else {
      _blikInputTimer = Timer(timeUntilExpiry, _handleBlikInputTimeout);
    }
  }

  void _handleBlikInputTimeout() {
    _blikInputTimer?.cancel();
    if (mounted) {
      print("[TakerSubmitBlikScreen] BLIK input timer expired.");
      ref.read(activeOfferProvider.notifier).state = null;
      // Use localized string
      final strings = AppLocalizations.of(context)!;
      _resetToOfferList(strings.blikInputTimeExpired);
    }
  }

  void _resetToOfferList(String message) {
    _blikInputTimer?.cancel();
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    Navigator.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go("/offers");
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
        }
      }
    });
  }

  Future<String?> _promptForLightningAddress(
    BuildContext context,
    KeyService keyService,
  ) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final strings = AppLocalizations.of(context)!; // Get strings
        return AlertDialog(
          // Reuse existing key (or editLightningAddress)
          title: Text(strings.enterLightningAddress),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                // Reuse existing key
                hintText: strings.lightningAddressHint,
                // Reuse existing key
                labelText: strings.lightningAddressLabel,
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  // Reuse existing key
                  return strings.lightningAddressInvalid;
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              // Reuse existing key
              child: Text(strings.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              // Reuse existing key
              child: Text(strings.saveAndContinue),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final address = controller.text;
                  showDialog(
                    context: dialogContext,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );
                  try {
                    await keyService.saveLightningAddress(address);
                    Navigator.of(dialogContext).pop(); // Pop loading
                    Navigator.of(dialogContext).pop(address); // Return saved
                  } catch (e) {
                    Navigator.of(dialogContext).pop(); // Pop loading
                    // Reuse existing key with placeholder
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(strings.errorSavingAddress(e.toString())),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitBlik() async {
    _blikInputTimer?.cancel();

    final offer = ref.read(activeOfferProvider);
    final blikCode = _blikController.text;
    final takerId = ref.read(publicKeyProvider).value;
    final keyService = ref.read(keyServiceProvider);
    String? lnAddress = ref.read(lightningAddressProvider).value;
    final strings = AppLocalizations.of(context)!; // Get strings

    // --- Validations ---
    if (takerId == null) {
      // Reuse existing key
      ref.read(errorProvider.notifier).state = strings.errorPublicKeyNotLoaded;
      if (offer != null) _startBlikInputTimer(offer);
      return;
    }
    if (offer == null ||
        offer.status != OfferStatus.reserved.name ||
        offer.reservedAt == null) {
      // Use localized string
      ref.read(errorProvider.notifier).state = strings.errorOfferStateChanged;
      // Use localized string
      _resetToOfferList(strings.errorOfferStateNotValid);
      return;
    }
    if (blikCode.isEmpty ||
        blikCode.length != 6 ||
        int.tryParse(blikCode) == null) {
      // Use localized string
      ref.read(errorProvider.notifier).state = strings.errorInvalidBlikFormat;
      _startBlikInputTimer(offer);
      return;
    }
    if (lnAddress == null || lnAddress.isEmpty || !lnAddress.contains('@')) {
      print("[TakerSubmitBlikScreen] LN Address missing, prompting user.");
      lnAddress = await _promptForLightningAddress(context, keyService);
      if (lnAddress == null) {
        print("[TakerSubmitBlikScreen] User cancelled LN Address prompt.");
        // Use localized string
        ref.read(errorProvider.notifier).state =
            strings.errorLightningAddressRequired;
        _startBlikInputTimer(offer);
        return;
      }
      print("[TakerSubmitBlikScreen] LN Address obtained: $lnAddress");
    }
    // --- End Validations ---

    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.submitBlikCode(
        offerId: offer.id,
        takerId: takerId,
        blikCode: blikCode,
        takerLightningAddress: lnAddress,
      );

      final updatedOffer = offer.copyWith(
        status: OfferStatus.blikReceived.name,
        blikReceivedAt: DateTime.now(),
        blikCode: blikCode,
      );
      ref.read(activeOfferProvider.notifier).state = updatedOffer;

      print(
        "[TakerSubmitBlikScreen] BLIK submitted. Navigating to WaitConfirmation.",
      );
      if (mounted) {
        context.go('/wait-confirmation', extra: updatedOffer);
      }
    } catch (e) {
      // Use localized string with placeholder
      ref.read(errorProvider.notifier).state = strings.errorSubmittingBlik(
        e.toString(),
      );
      if (mounted) {
        _startBlikInputTimer(offer);
      }
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final textData = await Clipboard.getData(Clipboard.kTextPlain);
    // FlutterClipboard.paste().then((value) {
    setState(() {
      if (textData != null &&
          textData.text != null &&
          textData.text!.isNotEmpty) {
        print("clipboard.getData:${textData.text}");
        final pastedText = textData.text!;
        final digitsOnly = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
        if (digitsOnly.length == 6) {
          _blikController.text = digitsOnly;
          _blikController.selection = TextSelection.fromPosition(
            TextPosition(offset: _blikController.text.length),
          );
          // Use localized string
          final strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.blikPasted),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          // Use localized string
          final strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorClipboardInvalidBlik)),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final isLoadingDetails = _isLoadingDetails;
    final errorMessage = ref.watch(errorProvider);
    final activeOffer = ref.watch(activeOfferProvider);
    // Use initialOffer only as a fallback while loading details
    final displayOffer = activeOffer ?? widget.initialOffer;
    final strings = AppLocalizations.of(context)!; // Get strings

    if (isLoadingDetails) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(key: Key("loading_details")),
        ),
      );
    }

    // If activeOffer is null after loading, it means fetch failed/reset was called
    if (activeOffer == null) {
      return Scaffold(
        // Use localized string
        body: Center(child: Text(strings.errorOfferDetailsNotLoaded)),
      );
    }

    // --- Main UI Build ---
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
            // Use localized string
            Text(
              strings.selectedOfferLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: Text(
                  "${formatDouble(displayOffer.fiatAmount)} ${displayOffer.fiatCurrency}",
                ),
                // Use localized string with placeholders
                subtitle: Text(
                  strings.offerDetailsSubtitle(
                    displayOffer.amountSats,
                    displayOffer.takerFees??0,
                    displayOffer.status,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
            const SizedBox(height: 20),
            // Use reservedAt from the *active* offer state
            if (activeOffer.reservedAt != null && _maxBlikInputTime != null)
              BlikInputProgressIndicator(
                key: ValueKey('blik_timer_${activeOffer.id}'),
                reservedAt: activeOffer.reservedAt!,
                maxDuration: _maxBlikInputTime!,
              )
            else if (activeOffer.reservedAt != null &&
                _maxBlikInputTime == null)
              Text(
                strings.errorLoadingTimeoutConfiguration,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ) // Removed comma that was here
            else
              const SizedBox(
                height: 20,
              ), // Should not happen if validation passed
            const SizedBox(height: 15),
            // Use localized string
            Text(
              strings.enterBlikCodeLabel,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _blikController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      // Use localized string
                      labelText: strings.blikCodeLabel,
                      counterText: "",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.content_paste),
                  // Use localized string
                  tooltip: strings.pasteFromClipboardTooltip,
                  onPressed: _pasteFromClipboard,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _submitBlik,
              child:
                  isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      // Use localized string
                      : Text(strings.submitBlikButton),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDouble(double value) {
  // Check if the value is effectively a whole number
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    // Format with up to 2 decimal places, removing trailing zeros
    String asString = value.toStringAsFixed(2);
    // Remove trailing zeros after decimal point
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      // Remove decimal point if it's the last character
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}
