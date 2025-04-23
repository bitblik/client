import 'dart:async';
import 'package:bitblik/src/screens/taker_flow/taker_payment_failed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerPhase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart';
import '../../services/api_service.dart'; // Needed for potential status checks

class TakerWaitConfirmationScreen extends ConsumerStatefulWidget {
  final Offer offer; // Accept the offer directly - REINSTATED

  const TakerWaitConfirmationScreen({
    required this.offer,
    super.key,
  }); // REINSTATED

  @override
  ConsumerState<TakerWaitConfirmationScreen> createState() =>
      _TakerWaitConfirmationScreenState();
}

class _TakerWaitConfirmationScreenState
    extends ConsumerState<TakerWaitConfirmationScreen> {
  Timer? _confirmationTimer;
  int _confirmationCountdownSeconds = 120;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;
  bool _timersInitialized = false;

  @override
  void initState() {
    super.initState();
    // Validate passed offer immediately
    if (widget.offer.status != OfferStatus.blikReceived.name &&
        widget.offer.status != OfferStatus.blikSentToMaker.name &&
        widget.offer.status != OfferStatus.makerConfirmed.name) {
      print(
        "[TakerWaitConfirmation initState] Error: Received invalid offer state: ${widget.offer.status}. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resetToOfferList("Error: Invalid offer state received.");
        }
      });
    } else {
      // Start timers when the screen initializes if state is valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Pass initial offer to start timers
          _initializeTimers(widget.offer);
        }
      });
    }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _initializeTimers(Offer offer) {
    if (_timersInitialized || !mounted) return;
    print("[TakerWaitConfirmation] Initializing timers...");
    _startConfirmationTimer(offer); // Pass offer
    _startStatusCheckTimer(offer); // Pass offer
    _timersInitialized = true;
  }

  // --- Confirmation Timer (120s) ---
  void _startConfirmationTimer(Offer offer) {
    // Accept offer
    if (_confirmationTimer?.isActive ?? false) return;
    _confirmationTimer?.cancel();
    if (!mounted) return;

    final startTime = offer.blikReceivedAt ?? DateTime.now(); // Use offer data
    final expiresAt = startTime.add(const Duration(seconds: 120));
    final now = DateTime.now();
    final initialRemaining = expiresAt.difference(now);

    print(
      "[TakerWaitConfirmation] Starting confirmation timer. Expires ~ $expiresAt",
    );

    if (initialRemaining.isNegative) {
      _handleConfirmationTimeout();
    } else {
      setState(() {
        _confirmationCountdownSeconds = initialRemaining.inSeconds.clamp(
          0,
          120,
        );
      });
      _confirmationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_confirmationCountdownSeconds > 0) {
            _confirmationCountdownSeconds--;
          } else {
            timer.cancel();
            _handleConfirmationTimeout();
          }
        });
      });
    }
  }

  void _handleConfirmationTimeout() {
    _confirmationTimer?.cancel();
    _statusCheckTimer?.cancel();
    if (mounted) {
      print("[TakerWaitConfirmation] Confirmation timer expired.");
      ref.read(activeOfferProvider.notifier).state = null;
      _resetToOfferList('Maker confirmation timed out (120s).');
    }
  }

  // --- Status Check Timer ---
  void _startStatusCheckTimer(Offer offer) {
    // Accept offer
    _statusCheckTimer?.cancel();
    // Delay first check slightly
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkOfferStatus(); // Initial check uses provider state
    });
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isCheckingStatus) {
        _checkOfferStatus(); // Subsequent checks use provider state
      }
    });
  }

  Future<void> _checkOfferStatus() async {
    // No longer needs offer param here
    if (_isCheckingStatus || !mounted) return;

    // Read the *latest* offer state from the provider for checking
    final currentOffer = ref.read(activeOfferProvider);
    if (currentOffer == null) {
      print(
        "[TakerWaitConfirmation _checkOfferStatus] Error: Active offer is null. Resetting.",
      );
      _resetToOfferList("Active offer details lost.");
      return;
    }
    final paymentHash = currentOffer.holdInvoicePaymentHash;
    if (paymentHash == null) {
      print(
        "[TakerWaitConfirmation _checkOfferStatus] CRITICAL Error: Payment hash is null in active offer. Resetting.",
      );
      _resetToOfferList("Internal error: Offer details incomplete.");
      return;
    }

    OfferStatus currentStatusEnum;
    try {
      currentStatusEnum = OfferStatus.values.byName(currentOffer.status);
    } catch (e) {
      print(
        "[TakerWaitConfirmation _checkOfferStatus] Error: Invalid status '${currentOffer.status}'. Resetting.",
      );
      _resetToOfferList("Offer has an invalid status.");
      return;
    }

    if (currentStatusEnum != OfferStatus.blikReceived &&
        currentStatusEnum != OfferStatus.blikSentToMaker &&
        currentStatusEnum != OfferStatus.makerConfirmed) {
      print(
        "[TakerWaitConfirmation] Offer status ($currentStatusEnum) no longer waiting. Stopping poll.",
      );
      _statusCheckTimer?.cancel();
      if (currentStatusEnum == OfferStatus.settled ||
          currentStatusEnum == OfferStatus.takerPaid) {
        _handlePaymentSuccess();
      } else {
        if (currentStatusEnum == OfferStatus.takerPaymentFailed) {
          final destinationScreen = TakerPaymentFailedScreen(
            offer: currentOffer,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => destinationScreen),
          );
        }
        // _resetToOfferList(
        //   "Offer is no longer awaiting confirmation (Status: $currentStatusEnum).",
        // );
      }
      return;
    }

    _isCheckingStatus = true;
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final statusString = await apiService.getOfferStatus(paymentHash);
      print(
        "[TakerWaitConfirmation] Poll result for $paymentHash: $statusString",
      );

      if (!mounted) return;

      if (statusString == null) {
        print("[TakerWaitConfirmation] Warning: Status check returned null.");
      } else {
        OfferStatus fetchedStatus;
        try {
          fetchedStatus = OfferStatus.values.byName(statusString);
        } catch (e) {
          print(
            "[TakerWaitConfirmation] Error: Received unknown status '$statusString'. Resetting.",
          );
          _statusCheckTimer?.cancel();
          _confirmationTimer?.cancel();
          _resetToOfferList(
            "Received an unexpected offer status from the server.",
          );
          return;
        }

        // --- Handle Status Updates ---
        if (fetchedStatus == OfferStatus.settled ||
            fetchedStatus == OfferStatus.takerPaid) {
          print(
            "[TakerWaitConfirmation] Offer settled/paid (Status: $fetchedStatus). Payment successful!",
          );
          ref.read(activeOfferProvider.notifier).state = currentOffer.copyWith(
            status: fetchedStatus.name,
          );
          _handlePaymentSuccess();
        } else if (fetchedStatus == OfferStatus.funded ||
            fetchedStatus == OfferStatus.expired) {
          print(
            "[TakerWaitConfirmation] Offer reverted or expired (Status: $fetchedStatus). Resetting.",
          );
          _statusCheckTimer?.cancel();
          _confirmationTimer?.cancel();
          ref.read(activeOfferProvider.notifier).state = null;
          _resetToOfferList("Offer was cancelled or expired.");
        } else if (fetchedStatus != currentStatusEnum) {
          print(
            "[TakerWaitConfirmation] Offer status updated to $fetchedStatus. Updating provider.",
          );
          ref.read(activeOfferProvider.notifier).state = currentOffer.copyWith(
            status: fetchedStatus.name,
          );
        } else {
          print(
            "[TakerWaitConfirmation] Still waiting for confirmation (Status: $fetchedStatus).",
          );
        }
        // --- End Handle Status Updates ---
      }
    } catch (e) {
      print('[TakerWaitConfirmation] Error checking offer status: $e');
    } finally {
      if (mounted) {
        _isCheckingStatus = false;
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  void _handlePaymentSuccess() {
    _statusCheckTimer?.cancel();
    _confirmationTimer?.cancel();
    if (mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Payment Successful! You will receive the funds shortly.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _resetToOfferList("Offer completed successfully!");
        }
      });
    }
  }

  void _resetToOfferList(String message) {
    _confirmationTimer?.cancel();
    _statusCheckTimer?.cancel();
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    _timersInitialized = false; // Reset flag

    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.maybeOf(context);
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (scaffoldMessenger != null) {
            scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
          }
          if (navigator != null && navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
        }
      });
    } else if (mounted) {
      if (scaffoldMessenger != null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
      if (navigator != null && navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorProvider);
    // Watch the provider to rebuild when status changes or becomes null
    final currentOfferState = ref.watch(activeOfferProvider);

    // Use the initially passed offer for display if provider is null temporarily during reset
    final displayOffer = currentOfferState ?? widget.offer;

    // Handle case where offer becomes null (e.g., reset triggered)
    if (currentOfferState == null) {
      // Show loading indicator while reset/navigation is happening
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(key: Key("resetting"))),
      );
    }

    // Validate status using the latest state from provider
    OfferStatus currentStatusEnum;
    try {
      currentStatusEnum = OfferStatus.values.byName(currentOfferState.status);
    } catch (e) {
      print(
        "[TakerWaitConfirmation build] Error: Invalid status '${currentOfferState.status}'. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resetToOfferList("Offer has an invalid status.");
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(key: Key("invalid_status")),
        ),
      );
    }

    // Check if status is valid for this screen
    if (currentStatusEnum != OfferStatus.blikReceived &&
        currentStatusEnum != OfferStatus.blikSentToMaker &&
        currentStatusEnum != OfferStatus.makerConfirmed) {
      print(
        "[TakerWaitConfirmation build] Offer status ($currentStatusEnum) not valid for this screen. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          _resetToOfferList(
            "Offer is in an unexpected state ($currentStatusEnum).",
          );
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(key: Key("unexpected_status")),
        ),
      );
    }

    // Initialize timers only once when a valid offer is first available in the provider
    if (!_timersInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Pass the valid offer from the provider to initialize timers
        if (mounted) _initializeTimers(currentOfferState);
      });
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
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
              'Waiting for Maker confirmation: $_confirmationCountdownSeconds s',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    _confirmationCountdownSeconds <= 15
                        ? Colors.orange
                        : Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Confirm the amount is ${currentOfferState.fiatAmount} ${currentOfferState.fiatCurrency}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const Center(
                child: Icon(Icons.timer_outlined, size: 40, color: Colors.grey),
              ),
            const SizedBox(height: 20),
            const Text(
              'The Maker needs to use your BLIK code and confirm the payment was successful in their app. You will receive the Lightning payment automatically after confirmation.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '(Offer Status: ${displayOffer.status})', // Use latest status
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
