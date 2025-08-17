import '../../../i18n/gen/strings.g.dart'; // Corrected Slang import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../models/offer.dart';
import '../../providers/providers.dart';

// Enum to manage screen state
enum PaymentRetryState { initial, loading, success, failed }

class TakerPaymentFailedScreen extends ConsumerStatefulWidget {
  // Changed to StatefulWidget
  final Offer offer;

  const TakerPaymentFailedScreen({super.key, required this.offer});

  @override
  ConsumerState<TakerPaymentFailedScreen> createState() =>
      _TakerPaymentFailedScreenState();
}

class _TakerPaymentFailedScreenState
    extends ConsumerState<TakerPaymentFailedScreen> {
  // State class
  final _bolt11Controller = TextEditingController();
  PaymentRetryState _currentState = PaymentRetryState.initial; // Initial state
  String? _errorMessage; // To store error messages

  void _handleStatusUpdate(OfferStatus? status) {
    if (status == null) return;

    if (mounted) {
      if (status == OfferStatus.takerPaid) {
        setState(() {
          _currentState = PaymentRetryState.success;
        });
      } else if (status == OfferStatus.takerPaymentFailed) {
        setState(() {
          _currentState = PaymentRetryState.failed;
          _errorMessage = t.taker.paymentFailed.errors.paymentRetryFailed;
        });
      }
    }
  }

  @override
  void dispose() {
    _bolt11Controller.dispose();
    super.dispose();
  }

  Future<void> _retryPayment() async {
    final newInvoice = _bolt11Controller.text.trim();
    if (newInvoice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.taker.paymentFailed.errors.enterValidInvoice)),
      );
      return;
    }

    // Ensure the widget is still mounted before proceeding
    if (!mounted) return;

    setState(() {
      _currentState = PaymentRetryState.loading; // Set loading state
      _errorMessage = null; // Clear previous error
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final userPubkey = widget.offer.takerPubkey;
      if (userPubkey == null || userPubkey.isEmpty) {
        throw Exception(t.taker.paymentFailed.errors.takerPublicKeyNotFound);
      }

      // 1. Update the invoice first
      await apiService.updateTakerInvoice(
        offerId: widget.offer.id,
        newBolt11: newInvoice,
        userPubkey: userPubkey,
        coordinatorPubkey: widget.offer.coordinatorPubkey,
      );

      // 2. Trigger the retry mechanism on the backend
      await apiService.retryTakerPayment(
        offerId: widget.offer.id,
        userPubkey: userPubkey,
        coordinatorPubkey: widget.offer.coordinatorPubkey,
      );

      // 3. Set up subscription to listen for status updates
      if (mounted) {
        setState(() {
          _currentState =
              PaymentRetryState
                  .loading; // Keep loading while waiting for status
        });
      }
    } catch (e) {
      // Handle API errors or other exceptions, only if still mounted
      if (mounted) {
        setState(() {
          _currentState = PaymentRetryState.failed; // Set failed state on error
          _errorMessage = t.taker.paymentFailed.errors.updatingInvoice(
            details: e.toString(),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate net amount (moved here for access to widget.offer)
    final takerFees =
        widget.offer.takerFees ?? (widget.offer.amountSats * 0.005).ceil();
    final netAmountSats = widget.offer.amountSats - takerFees;

    // Set up status subscription
    final publicKeyAsync = ref.watch(publicKeyProvider);
    if (widget.offer.holdInvoicePaymentHash != null &&
        widget.offer.coordinatorPubkey != null) {
      publicKeyAsync.whenData((publicKey) {
        if (publicKey != null) {
          ref.listen<AsyncValue<OfferStatus?>>(
            offerStatusSubscriptionProvider((
              paymentHash: widget.offer.holdInvoicePaymentHash!,
              coordinatorPubKey: widget.offer.coordinatorPubkey!,
              userPubkey: publicKey,
            )),
            (previous, next) {
              next.whenData((status) {
                _handleStatusUpdate(status);
              });
            },
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentState == PaymentRetryState.success
              ? t.taker.paymentFailed.success.title
              : t.taker.paymentFailed.title,
        ),
        automaticallyImplyLeading: _currentState != PaymentRetryState.success,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: _buildContent(context, netAmountSats),
          ),
        ),
      ),
    );
  }

  // Helper method to build content based on state
  Widget _buildContent(BuildContext context, int netAmountSats) {
    switch (_currentState) {
      case PaymentRetryState.loading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(t.taker.paymentFailed.loading.processingPayment),
          ],
        );

      case PaymentRetryState.success:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              t.taker.paymentFailed.success.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              t.taker.paymentFailed.success.message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(activeOfferProvider.notifier)
                    .setActiveOffer(null);
                ref.read(appRoleProvider.notifier).state = AppRole.none;
                if (mounted) {
                  context.go('/');
                }
              },
              child: Text(t.common.buttons.goHome),
            ),
          ],
        );

      case PaymentRetryState.initial:
      case PaymentRetryState.failed:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              t.taker.paymentFailed.title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (widget.offer.takerLightningAddress != null &&
                widget.offer.takerLightningAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  t.lightningAddress.labels.short(
                    address: widget.offer.takerLightningAddress!,
                  ), // Corrected key
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 16),
            if (_currentState == PaymentRetryState.failed &&
                _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              t.taker.paymentFailed.instructions(
                netAmount: netAmountSats.toString(),
              ), // Corrected parameter name and type
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bolt11Controller,
              decoration: InputDecoration(
                labelText: t.taker.paymentFailed.form.newInvoiceLabel,
                hintText: t.taker.paymentFailed.form.newInvoiceHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryPayment,
              child: Text(t.taker.paymentFailed.actions.retryPayment),
            ),
          ],
        );
    }
  }
}
