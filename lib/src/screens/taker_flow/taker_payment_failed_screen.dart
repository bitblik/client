import 'package:bitblik/l10n/app_localizations.dart';
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

  @override
  void dispose() {
    _bolt11Controller.dispose();
    super.dispose();
  }

  Future<void> _retryPayment() async {
    final newInvoice = _bolt11Controller.text.trim();
    final strings = AppLocalizations.of(context)!;
    if (newInvoice.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.errorEnterValidInvoice)));
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
        // Use localized string if available, otherwise fallback
        throw Exception(
          strings.errorTakerPublicKeyNotFound ?? 'Taker public key not found.',
        );
      }

      // 1. Update the invoice first
      await apiService.updateTakerInvoice(
        offerId: widget.offer.id,
        newBolt11: newInvoice,
        userPubkey: userPubkey,
      );

      // 2. Trigger the retry mechanism on the backend
      await apiService.retryTakerPayment(
        offerId: widget.offer.id,
        userPubkey: userPubkey,
      );

      // 3. Poll for the final status (success or persistent failure)
      bool isFinalState = false;
      String? finalStatus;
      int attempts = 0;
      const maxAttempts = 15; // Poll for ~30 seconds

      while (!isFinalState && attempts < maxAttempts && mounted) {
        attempts++;
        await Future.delayed(const Duration(seconds: 2));
        // Ensure still mounted after delay
        if (!mounted) return;

        final currentStatus = await apiService.getOfferStatus(
          widget.offer.holdInvoicePaymentHash ?? '',
        );

        if (currentStatus == OfferStatus.takerPaid.name) {
          isFinalState = true;
          finalStatus = currentStatus;
        } else if (currentStatus == OfferStatus.takerPaymentFailed.name) {
          // Still failed after retry attempt, stop polling
          isFinalState = true;
          finalStatus = currentStatus;
        }
        // Continue polling if status is unchanged or in an intermediate state
      }

      // Update UI based on polling result, only if still mounted
      if (mounted) {
        if (finalStatus == OfferStatus.takerPaid.name) {
          setState(() {
            _currentState = PaymentRetryState.success; // Set success state
          });
        } else {
          // Still failed or timed out
          setState(() {
            _currentState = PaymentRetryState.failed; // Set failed state
            // Use specific localized string if available
            _errorMessage =
                strings.paymentRetryFailedError ??
                'Payment retry failed. Please check the invoice or try again later.';
          });
        }
      }
    } catch (e) {
      // Handle API errors or other exceptions, only if still mounted
      if (mounted) {
        setState(() {
          _currentState = PaymentRetryState.failed; // Set failed state on error
          // Use specific localized string if available
          _errorMessage = strings.errorUpdatingInvoice(e.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    // Calculate net amount (moved here for access to widget.offer)
    final takerFees =
        widget.offer.takerFees ?? (widget.offer.amountSats * 0.005).ceil();
    final netAmountSats = widget.offer.amountSats - takerFees;

    return Scaffold(
      appBar: AppBar(
        // Use localized string, dynamically update title based on state
        title: Text(
          _currentState == PaymentRetryState.success
              ? (strings.paymentSuccessfulTitle ??
                  'Payment Successful') // Use localized string with fallback
              : (strings.paymentFailedTitle ??
                  'Payment Failed'), // Use localized string with fallback
        ),
        // Hide back button automatically when navigation stack allows (or force hide on success)
        automaticallyImplyLeading: _currentState != PaymentRetryState.success,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Center content vertically
          child: SingleChildScrollView(
            // Allow scrolling if content overflows
            child: _buildContent(context, strings, netAmountSats),
          ),
        ),
      ),
    );
  }

  // Helper method to build content based on state
  Widget _buildContent(
    BuildContext context,
    AppLocalizations strings,
    int netAmountSats,
  ) {
    switch (_currentState) {
      case PaymentRetryState.loading:
        return const Column(
          // Wrap in column for centering
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processing payment..."), // Add loading text
          ],
        );

      case PaymentRetryState.success:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              strings.paymentSuccessfulTitle ??
                  'Payment Successful', // Use localized string with fallback
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              strings.paymentSuccessfulMessage ??
                  'Your payment has been processed successfully.', // Use localized string with fallback
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Clear active offer and go home
                ref.read(activeOfferProvider.notifier).state = null;
                // ALSO Reset the app role
                ref.read(appRoleProvider.notifier).state = AppRole.none;
                // Use context.go to navigate to the root ('/')
                if (mounted) {
                  context.go('/');
                }
              },
              child: Text(
                strings.goToHomeButton ?? 'Go to Home',
              ), // Use localized string with fallback
            ),
          ],
        );

      case PaymentRetryState.initial:
      case PaymentRetryState
          .failed: // Show error/retry UI for initial and failed states
        return Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              strings.paymentFailedTitle ??
                  'Payment Failed', // Use localized string with fallback
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (widget.offer.takerLightningAddress != null &&
                widget.offer.takerLightningAddress!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  strings.lightningAddressLabelShort(
                    // Assuming this key exists
                    widget.offer.takerLightningAddress!,
                  ),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              ),
            const SizedBox(height: 16),
            // Show specific error message if retry failed
            if (_currentState == PaymentRetryState.failed &&
                _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Text(
              // Assuming this key exists and takes an int parameter
              strings.paymentFailedInstructions(netAmountSats),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bolt11Controller,
              decoration: InputDecoration(
                // Use localized strings with fallbacks
                labelText:
                    strings.newLightningInvoiceLabel ??
                    'New Lightning Invoice (Bolt11)',
                hintText:
                    strings.newLightningInvoiceHint ??
                    'Enter the full ln... invoice',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryPayment, // Call the retry method
              // Use localized string with fallback
              child: Text(strings.submitNewInvoiceButton ?? 'Retry Payment'),
            ),
          ],
        );
    }
  }
}
