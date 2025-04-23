import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart';
import '../../services/api_service.dart';
import '../../services/key_service.dart'; // For LN Address prompt
import 'taker_wait_confirmation_screen.dart'; // Import the next screen

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
            'Submit BLIK within: $_remainingSeconds s',
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
  final Duration _maxBlikInputTime = const Duration(seconds: 20);
  bool _isLoadingDetails = true; // Flag for initial loading

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
      final publicKey = ref.read(publicKeyProvider).value;
      if (publicKey == null) {
        throw Exception("Public key not available.");
      }
      final apiService = ref.read(apiServiceProvider);
      // --- FIX: Use getMyActiveOffer ---
      final fullOfferData = await apiService.getMyActiveOffer(publicKey);

      if (!mounted) return;

      if (fullOfferData == null) {
        throw Exception(
          "Could not fetch active offer details. It might have expired.",
        );
      }

      final fullOffer = Offer.fromJson(fullOfferData);

      // Verify the fetched offer ID matches the initial one
      if (fullOffer.id != widget.initialOffer.id) {
        throw Exception(
          "Fetched active offer ID (${fullOffer.id}) does not match initial offer ID (${widget.initialOffer.id}). State mismatch?",
        );
      }
      // --- Validation ---
      if (fullOffer.status != OfferStatus.reserved.name) {
        throw Exception(
          "Offer is no longer in reserved state (${fullOffer.status}).",
        );
      }
      if (fullOffer.reservedAt == null) {
        throw Exception("Offer reservation timestamp is missing.");
      }
      if (fullOffer.holdInvoicePaymentHash == null) {
        throw Exception("Offer payment hash is missing after fetch.");
      }
      // --- End Validation ---

      ref.read(activeOfferProvider.notifier).state = fullOffer;
      print("[TakerSubmitBlikScreen] Successfully fetched full offer details.");

      _startBlikInputTimer(fullOffer);
      setState(() {
        _isLoadingDetails = false;
      });
    } catch (e) {
      print("[TakerSubmitBlikScreen] Error fetching full offer details: $e");
      if (mounted) {
        _resetToOfferList("Error loading offer details: ${e.toString()}");
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
      _resetToOfferList("Internal error: Offer details missing.");
      return;
    }

    final now = DateTime.now();
    final expiresAt = reservedAt.add(_maxBlikInputTime);
    final timeUntilExpiry = expiresAt.difference(now);

    print(
      "[TakerSubmitBlikScreen] Starting BLIK input timeout timer. Expires ~ $expiresAt",
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
      _resetToOfferList('BLIK input time expired.');
    }
  }

  void _resetToOfferList(String message) {
    _blikInputTimer?.cancel();
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (navigator != null) {
          navigator.popUntil((route) => route.isFirst);
        }
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
          title: const Text('Enter Lightning Address'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'user@domain.com',
                labelText: 'Lightning Address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid Lightning Address';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
            ),
            TextButton(
              child: const Text('Save & Continue'),
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
                      SnackBar(content: Text('Error saving address: $e')),
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
      ref.read(errorProvider.notifier).state = 'Error: Public key not loaded.';
      if (offer != null) _startBlikInputTimer(offer);
      return;
    }
    if (offer == null ||
        offer.status != OfferStatus.reserved.name ||
        offer.reservedAt == null) {
      ref.read(errorProvider.notifier).state = 'Error: Offer state changed.';
      _resetToOfferList("Error: Offer state is no longer valid.");
      return;
    }
    if (blikCode.isEmpty ||
        blikCode.length != 6 ||
        int.tryParse(blikCode) == null) {
      ref.read(errorProvider.notifier).state =
          'Please enter a valid 6-digit BLIK code.';
      if (offer != null) _startBlikInputTimer(offer);
      return;
    }
    if (lnAddress == null || lnAddress.isEmpty || !lnAddress.contains('@')) {
      print("[TakerSubmitBlikScreen] LN Address missing, prompting user.");
      lnAddress = await _promptForLightningAddress(context, keyService);
      if (lnAddress == null) {
        print("[TakerSubmitBlikScreen] User cancelled LN Address prompt.");
        ref.read(errorProvider.notifier).state =
            'Lightning Address is required.';
        if (offer != null) _startBlikInputTimer(offer);
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TakerWaitConfirmationScreen(offer: updatedOffer),
          ),
        );
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Error submitting BLIK: $e';
      if (mounted && offer != null) {
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
        if (textData!=null && textData.text != null && textData.text!.isNotEmpty) {
          print("clipboard.getData:${textData.text}");
          final pastedText = textData.text!;
          final digitsOnly = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
          if (digitsOnly.length == 6) {
            _blikController.text = digitsOnly;
            _blikController.selection = TextSelection.fromPosition(
              TextPosition(offset: _blikController.text.length),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pasted BLIK code.'),
                duration: Duration(seconds: 1),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Clipboard does not contain a valid 6-digit BLIK code.',
                ),
              ),
            );
          }
        }
        });
    //   final clipboard = ClipboardEvents.instance;
    //   if (clipboard!=null) {
    //     clipboard.registerPasteEventListener((event) async {
    //       // Requesting the clipboard reader will prevent the default paste action
    //       // such as inserting the text in editable element.
    //       await event.getClipboardReader().then((value) {
    //         value.getValue(Formats.plainText, (value) {
    //           if (value!=null && value.isNotEmpty) {
    //             final pastedText = value;
    //             final digitsOnly = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    //             if (digitsOnly.length == 6) {
    //               _blikController.text = digitsOnly;
    //               _blikController.selection = TextSelection.fromPosition(
    //                 TextPosition(offset: _blikController.text.length),
    //               );
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 const SnackBar(
    //                   content: Text('Pasted BLIK code.'),
    //                   duration: Duration(seconds: 1),
    //                 ),
    //               );
    //             } else {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 const SnackBar(
    //                   content: Text(
    //                     'Clipboard does not contain a valid 6-digit BLIK code.',
    //                   ),
    //                 ),
    //               );
    //             }
    //           } else {
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               const SnackBar(
    //                 content: Text('Clipboard is empty or does not contain text.'),
    //               ),
    //             );
    //           }
    //         });
    //       });
    //     });
    //   }
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
      return const Scaffold(
        body: Center(child: Text("Offer details could not be loaded.")),
      );
    }

    // --- Main UI Build ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter BLIK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _resetToOfferList("Cancelled Taker action."),
        ),
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
              Text(
                'Selected Offer:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Card(
                child: ListTile(
                  title: Text('Amount: ${displayOffer.amountSats} sats'),
                  subtitle: Text(
                    'Fee: ${displayOffer.feeSats} sats\nID: ${displayOffer.id.substring(0, 6)}...',
                  ),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 20),
              // Use reservedAt from the *active* offer state
              if (activeOffer.reservedAt != null)
                BlikInputProgressIndicator(
                  key: ValueKey('blik_timer_${activeOffer.id}'),
                  reservedAt: activeOffer.reservedAt!,
                  maxDuration: _maxBlikInputTime,
                )
              else
                const SizedBox(
                  height: 20,
                ), // Should not happen if validation passed
              const SizedBox(height: 15),
              const Text(
                'Enter 6-digit BLIK Code:',
                style: TextStyle(fontSize: 16),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'BLIK Code',
                        counterText: "",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.content_paste),
                    tooltip: 'Paste from Clipboard',
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
                        : const Text('Submit BLIK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
