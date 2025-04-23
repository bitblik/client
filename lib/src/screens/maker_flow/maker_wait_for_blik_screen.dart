import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/api_service.dart';
import '../../models/offer.dart';
import '../../widgets/progress_indicators.dart'; // Correct import for progress indicator
import 'maker_confirm_payment_screen.dart'; // Import next screen
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MakerWaitForBlikScreen extends ConsumerStatefulWidget {
  const MakerWaitForBlikScreen({super.key});

  @override
  ConsumerState<MakerWaitForBlikScreen> createState() =>
      _MakerWaitForBlikScreenState();
}

class _MakerWaitForBlikScreenState
    extends ConsumerState<MakerWaitForBlikScreen> {
  Timer? _statusCheckTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startStatusCheckTimer();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheckTimer() {
    _statusCheckTimer?.cancel();
    _checkOfferStatus(); // Check immediately
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isChecking) {
        await _checkOfferStatus();
      }
    });
  }

  Future<void> _checkOfferStatus() async {
    if (_isChecking) return;

    final offer = ref.read(activeOfferProvider);
    final paymentHash = offer?.holdInvoicePaymentHash;
    final makerId =
        ref.read(publicKeyProvider).value; // Needed for getMyActiveOffer

    if (paymentHash == null || makerId == null || offer == null) {
      print(
        "[MakerWaitForBlik] Error: Missing offer, payment hash or public key.",
      );
      if (offer == null && mounted) {
        _resetToRoleSelection(
          AppLocalizations.of(context)!.errorOfferDetailsMissing,
        );
      }
      return;
    }

    // Check if reservation time expired locally first (using the progress indicator's logic)
    if (offer.reservedAt != null) {
      final expiresAt = offer.reservedAt!.add(
        const Duration(seconds: 20),
      ); // Use 20s timeout
      if (DateTime.now().isAfter(expiresAt)) {
        print(
          "[MakerWaitForBlik] Reservation time likely expired locally. Popping back.",
        );
        _statusCheckTimer?.cancel(); // Stop polling
        // No need to invalidate providers here, let the previous screen handle it if necessary
        if (mounted) {
          print(
            "[MakerWaitForBlik] Popping self and pushing MakerConfirmPaymentScreen...",
          );
          // Pop the current screen first
          Navigator.of(context).pop();
          // Then push the confirmation screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MakerConfirmPaymentScreen(),
            ),
          );
          Navigator.of(context).pop(); // Pop THIS screen only
        }
        return; // Don't proceed with API check if locally expired
      }
    }

    _isChecking = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final statusString = await apiService.getOfferStatus(paymentHash);
      print("[MakerWaitForBlik] Poll result for $paymentHash: $statusString");

      if (statusString == null) {
        print("[MakerWaitForBlik] Warning: Status check returned null.");
        return; // Exit early, finally block will still run
      }

      var currentStatus = OfferStatus.values.byName(
        statusString,
      ); // Changed to var

      // Update provider if status changed on backend
      // Important: Read the offer *again* from the provider *after* potential update
      Offer offerToCheck = offer; // Start with the offer read at the beginning
      if (offer.status != currentStatus.name) {
        final updatedOfferData = await apiService.getMyActiveOffer(makerId);
        if (updatedOfferData != null) {
          final updatedOffer = Offer.fromJson(updatedOfferData);
          ref.read(activeOfferProvider.notifier).state = updatedOffer;
          offerToCheck =
              updatedOffer; // Use the updated offer for subsequent checks
          print(
            "[MakerWaitForBlik] Updated activeOfferProvider with status: ${offerToCheck.status}",
          );
          // Re-check status from updated offer
          currentStatus = OfferStatus.values.byName(offerToCheck.status);
        } else {
          print(
            "[MakerWaitForBlik] Warning: Failed to fetch updated offer details after status change.",
          );
          // Keep polling with old status assumption, offerToCheck remains the initial offer
        }
      }

      // Now use offerToCheck for ID and makerId if needed
      final String offerId = offerToCheck.id;
      // makerId was already fetched

      if (currentStatus == OfferStatus.blikReceived ||
          currentStatus == OfferStatus.blikSentToMaker) {
        print(
          "[MakerWaitForBlik] BLIK received/sent. Fetching code via API...",
        );
        _statusCheckTimer?.cancel();

        // --- Call API to get BLIK code using offerId and makerId ---
        try {
          print(
            "[MakerWaitForBlik] Calling getBlikCodeForMaker with offerId: $offerId, makerId: $makerId",
          );
          final blikCode = await apiService.getBlikCodeForMaker(
            offerId,
            makerId,
          );
          print(
            "[MakerWaitForBlik] API returned blikCode: $blikCode",
          ); // Log the raw result

          if (blikCode != null && blikCode.isNotEmpty) {
            print(
              "[MakerWaitForBlik] BLIK code is valid. Storing in provider...",
            );
            ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
            print("[MakerWaitForBlik] Stored BLIK code from API: $blikCode");

            if (mounted) {
              print(
                "[MakerWaitForBlik] Navigating to MakerConfirmPaymentScreen...",
              );
              Navigator.of(context).pushReplacement(
                // Use pushReplacement
                MaterialPageRoute(
                  builder: (_) => const MakerConfirmPaymentScreen(),
                ),
              );
            }
          } else {
            // BLIK code is missing even though status is correct - backend issue?
            print(
              "[MakerWaitForBlik] Error: Status is ${currentStatus.name} but API returned no BLIK code. Resetting.",
            );
            if (mounted) {
              _resetToRoleSelection(AppLocalizations.of(context)!.error);
            }
          }
        } catch (e) {
          print("[MakerWaitForBlik] Error calling getBlikCodeForMaker: $e");
          if (mounted) {
            _resetToRoleSelection(AppLocalizations.of(context)!.error);
          }
        }
      } else if (currentStatus == OfferStatus.funded) {
        print(
          "[MakerWaitForBlik] Offer reverted to FUNDED (Taker likely timed out). Popping back.",
        );
        _statusCheckTimer?.cancel();
        if (mounted) {
          print(
            "[MakerWaitForBlik] Popping self and pushing MakerConfirmPaymentScreen...",
          );
          // Pop the current screen first
          Navigator.of(context).pop();
          // Then push the confirmation screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MakerConfirmPaymentScreen(),
            ),
          );
          Navigator.of(context).pop();
        }
      } else if (currentStatus == OfferStatus.reserved) {
        print(
          "[MakerWaitForBlik] Still waiting for BLIK (Status: $currentStatus).",
        );
        // Stay on this screen
      }
      // Handle unexpected states
      else {
        print(
          "[MakerWaitForBlik] Offer in unexpected state ($currentStatus). Resetting.",
        );
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(AppLocalizations.of(context)!.error);
        }
      }
    } catch (e) {
      print('[MakerWaitForBlik] Error checking offer status: $e');
    } finally {
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  void _resetToRoleSelection(String message) {
    _statusCheckTimer?.cancel();
    ref.read(appRoleProvider.notifier).state = AppRole.none;
    ref.read(activeOfferProvider.notifier).state = null;
    ref.read(holdInvoiceProvider.notifier).state = null;
    ref.read(paymentHashProvider.notifier).state = null;
    ref.read(receivedBlikCodeProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void _goHome() {
    _statusCheckTimer?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final offer = ref.watch(activeOfferProvider);

    if (offer == null || offer.reservedAt == null) {
      // Should ideally not happen if navigated correctly, but handle defensively
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.error)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.errorOfferDetailsMissing),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waitingForBlik),
        automaticallyImplyLeading:
            false, // Prevent back button since we handle navigation
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: AppLocalizations.of(context)!.goHome,
            onPressed:
                _goHome, // Allow going home, but maybe reconsider cancellation here?
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.offerReservedByTaker,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.waitingForTakerBlik,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Show the 20s reservation progress bar
              ReservationProgressIndicator(
                key: ValueKey('res_timer_${offer.id}'), // Use offer ID in key
                reservedAt: offer.reservedAt!,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(), // General waiting indicator
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.takerHas20Seconds,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              // Note: Cancellation might be complex here as offer is reserved.
              // Consider disabling or handling differently. For now, removed.
            ],
          ),
        ),
      ),
    );
  }
}
