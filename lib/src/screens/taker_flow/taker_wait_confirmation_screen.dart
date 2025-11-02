import 'dart:async';

import '../../../i18n/gen/strings.g.dart'; // Import Slang
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerPhase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart';
import '../../providers/providers.dart';

class TakerWaitConfirmationScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const TakerWaitConfirmationScreen({required this.offer, super.key});

  @override
  ConsumerState<TakerWaitConfirmationScreen> createState() =>
      _TakerWaitConfirmationScreenState();
}

class _TakerWaitConfirmationScreenState
    extends ConsumerState<TakerWaitConfirmationScreen> {
  Timer? _confirmationTimer;
  int _confirmationCountdownSeconds = 120;
  bool _timersInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer.status != OfferStatus.blikReceived.name &&
        widget.offer.status != OfferStatus.blikSentToMaker.name &&
        widget.offer.status != OfferStatus.makerConfirmed.name) {
      print(
        "[TakerWaitConfirmation initState] Error: Received invalid offer state: ${widget.offer.status}. Resetting.",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resetToOfferList(
            t.taker.waitConfirmation.errors.invalidOfferStateReceived,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    super.dispose();
  }

  void _initializeOrUpdateCountdownTimer(Offer offer) {
    print("[TakerWaitConfirmation] Initializing/Updating countdown timer...");
    _startConfirmationTimer(offer);
    _timersInitialized = true;
  }

  void _startConfirmationTimer(Offer offer) {
    _confirmationTimer?.cancel();
    if (!mounted) return;

    final startTime = offer.blikReceivedAt ?? DateTime.now();
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
    if (mounted) {
      print("[TakerWaitConfirmation] Confirmation timer expired.");
    }
  }

  Future<void> _resetToOfferList(String message) async {
    _confirmationTimer?.cancel();
    await ref.read(activeOfferProvider.notifier).setActiveOffer(null);
    ref.read(errorProvider.notifier).state = null;
    _timersInitialized = false;

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
      context.go('/offers');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the active offer provider to get real-time status updates
    final offer = ref.watch(activeOfferProvider);

    // Use addPostFrameCallback to handle navigation after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (offer == null) {
        print("[TakerWaitConfirmation] Active offer is null. Resetting.");
        _resetToOfferList(t.offers.status.cancelled);
        return;
      }

      final currentStatusEnum = offer.statusEnum;

      if (currentStatusEnum == OfferStatus.makerConfirmed ||
          currentStatusEnum == OfferStatus.settled ||
          currentStatusEnum == OfferStatus.payingTaker ||
          currentStatusEnum == OfferStatus.takerPaid) {
        print(
          "[TakerWaitConfirmation] Status is $currentStatusEnum. Navigating to process screen.",
        );
        // final paymentHash = offer.holdInvoicePaymentHash;
        // if (paymentHash != null) {
        //   ref.read(paymentHashProvider.notifier).state = paymentHash;
          _confirmationTimer?.cancel();
          context.go("/paying-taker");
        // } else {
        //   _resetToOfferList(t.system.errors.internalOfferIncomplete);
        // }
      } else if (currentStatusEnum == OfferStatus.invalidBlik) {
        _confirmationTimer?.cancel();
        context.go('/taker-invalid-blik', extra: offer);
      } else if (currentStatusEnum == OfferStatus.conflict) {
        _confirmationTimer?.cancel();
        context.go('/taker-conflict', extra: offer.id);
      } else if (currentStatusEnum == OfferStatus.takerPaymentFailed) {
        // final paymentHash = offer.holdInvoicePaymentHash;
        // if (paymentHash != null) {
        //   ref.read(paymentHashProvider.notifier).state = paymentHash;
          _confirmationTimer?.cancel();
          context.go('/paying-taker');
        // } else {
        //   _resetToOfferList(t.system.errors.internalOfferIncomplete);
        // }
      } else if (currentStatusEnum != OfferStatus.blikReceived &&
          currentStatusEnum != OfferStatus.blikSentToMaker) {
        _resetToOfferList(
          t.offers.errors.unexpectedStateWithStatus(
            status: currentStatusEnum.name,
          ),
        );
      }
    });

    if (offer == null) {
      // Show a loading indicator while waiting for the offer or resetting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Initialize timer if not already done
    if (!_timersInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initializeOrUpdateCountdownTimer(offer);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.taker.waitConfirmation.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: t.common.buttons.goHome,
            onPressed: () {
              _resetToOfferList(t.taker.waitConfirmation.navigatedHome);
            },
          ),
        ],
      ),
      body: _buildWaitingContent(context, offer),
    );
  }

  Widget _buildWaitingContent(BuildContext context, Offer offer) {
    final errorMessage = ref.watch(errorProvider);

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
              t.common.labels.status(status: offer.status),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              t.taker.waitConfirmation.waitingMakerConfirmation(
                seconds: _confirmationCountdownSeconds,
              ),
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
              t.taker.waitConfirmation.importantBlikAmountConfirmation(
                amount: formatDouble(offer.fiatAmount ?? 0.0),
                currency: offer.fiatCurrency,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.timer_outlined, size: 40, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(t.blik.instructions.taker, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

String formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  } else {
    String asString = value.toStringAsFixed(2);
    if (asString.contains('.')) {
      asString = asString.replaceAll(RegExp(r'0+$'), '');
      if (asString.endsWith('.')) {
        asString = asString.substring(0, asString.length - 1);
      }
    }
    return asString;
  }
}
