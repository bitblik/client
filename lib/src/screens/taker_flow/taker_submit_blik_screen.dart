import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../i18n/gen/strings.g.dart';
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
          Text(
            t.taker.submitBlik.timeLimit(seconds: _remainingSeconds),
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
        throw Exception(t.taker.paymentProcess.errors.noPublicKey);
      }

      final fullOfferData = await apiService.getMyActiveOffer(publicKey);

      if (!mounted) return;

      if (fullOfferData == null) {
        throw Exception(t.maker.payInvoice.errors.couldNotFetchActive);
      }

      final fullOffer = Offer.fromJson(fullOfferData);

      // Verify the fetched offer ID matches the initial one
      if (fullOffer.id != widget.initialOffer.id) {
        throw Exception(
          t.taker.submitBlik.errors.fetchedIdMismatch(
            fetchedId: fullOffer.id,
            initialId: widget.initialOffer.id,
          ),
        );
      }
      // --- Validation ---
      if (fullOffer.status != OfferStatus.reserved.name) {
        throw Exception(
          t.reservations.errors.notReserved(status: fullOffer.status),
        );
      }
      if (fullOffer.reservedAt == null) {
        throw Exception(t.reservations.errors.timestampMissing);
      }
      if (fullOffer.holdInvoicePaymentHash == null) {
        throw Exception(t.taker.submitBlik.errors.paymentHashMissing);
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
        _resetToOfferList(
          t.offers.errors.loadingDetails(details: e.toString()),
        );
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
      _resetToOfferList(t.offers.errors.detailsMissing);
      return;
    }

    final now = DateTime.now();
    // Ensure _maxBlikInputTime is non-null before proceeding
    if (_maxBlikInputTime == null) {
      print(
        "[TakerSubmitBlikScreen] Error: _maxBlikInputTime is null in _startBlikInputTimer. Resetting.",
      );
      _resetToOfferList("${t.offers.errors.detailsMissing} (Timeout config)");
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
      _resetToOfferList(t.taker.submitBlik.timeExpired);
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
        return AlertDialog(
          title: Text(t.lightningAddress.prompts.enter),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: t.lightningAddress.labels.hint,
                labelText: t.lightningAddress.labels.address,
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return t.lightningAddress.prompts.invalid;
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t.common.buttons.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: Text(t.common.buttons.saveAndContinue),
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
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(
                          t.lightningAddress.errors.saving(
                            details: e.toString(),
                          ),
                        ),
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

    // --- Validations ---
    if (takerId == null) {
      ref.read(errorProvider.notifier).state =
          t.taker.paymentProcess.errors.noPublicKey;
      if (offer != null) _startBlikInputTimer(offer);
      return;
    }
    if (offer == null ||
        offer.status != OfferStatus.reserved.name ||
        offer.reservedAt == null) {
      ref.read(errorProvider.notifier).state =
          t.taker.submitBlik.errors.stateChanged;
      _resetToOfferList(t.taker.submitBlik.errors.stateNotValid);
      return;
    }
    if (blikCode.isEmpty ||
        blikCode.length != 6 ||
        int.tryParse(blikCode) == null) {
      ref.read(errorProvider.notifier).state =
          t.taker.submitBlik.validation.invalidFormat;
      _startBlikInputTimer(offer);
      return;
    }
    if (lnAddress == null || lnAddress.isEmpty || !lnAddress.contains('@')) {
      print("[TakerSubmitBlikScreen] LN Address missing, prompting user.");
      lnAddress = await _promptForLightningAddress(context, keyService);
      if (lnAddress == null) {
        print("[TakerSubmitBlikScreen] User cancelled LN Address prompt.");
        ref.read(errorProvider.notifier).state =
            t.lightningAddress.prompts.required;
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
      ref.read(errorProvider.notifier).state = t.taker.submitBlik.errors
          .submitting(details: e.toString());
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.taker.submitBlik.feedback.pasted),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.taker.submitBlik.errors.clipboardInvalid)),
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
        body: Center(child: Text(t.offers.errors.detailsNotLoaded)),
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
            Text(
              t.offers.display.selectedOffer,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Card(
              child: ListTile(
                title: Text(
                  "${formatDouble(displayOffer.fiatAmount)} ${displayOffer.fiatCurrency}",
                ),
                subtitle: Text(
                  t.offers.details.takerFeeWithStatus(
                    fee: displayOffer.takerFees ?? 0,
                    status: displayOffer.status,
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
                t.system.errors.loadingTimeoutConfig,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              const SizedBox(
                height: 20,
              ), // Should not happen if validation passed
            const SizedBox(height: 15),
            Text(
              t.taker.submitBlik.title,
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
                      labelText: t.taker.submitBlik.label,
                      counterText: "",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: t.common.clipboard.pasteFromClipboard,
                  onPressed: _pasteFromClipboard,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading ? null : _submitBlik,
              child:
                  isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(t.taker.submitBlik.actions.submit),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
              onPressed:
                  isLoading
                      ? null
                      : () async {
                        final offer = ref.read(activeOfferProvider);
                        final takerId = ref.read(publicKeyProvider).value;
                        if (offer == null || takerId == null) return;
                        ref.read(isLoadingProvider.notifier).state = true;
                        ref.read(errorProvider.notifier).state = null;
                        try {
                          final apiService = ref.read(apiServiceProvider);
                          await apiService.cancelReservation(offer.id, takerId);
                          if (mounted) {
                            _resetToOfferList(
                              t.reservations.feedback.cancelled,
                            );
                          }
                        } catch (e) {
                          ref.read(errorProvider.notifier).state = t
                              .reservations
                              .errors
                              .cancelling(error: e.toString());
                          if (mounted) {
                            _startBlikInputTimer(offer);
                          }
                        } finally {
                          if (mounted) {
                            ref.read(isLoadingProvider.notifier).state = false;
                          }
                        }
                      },
              child: Text(t.reservations.actions.cancel),
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
