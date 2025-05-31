import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../models/offer.dart';
import '../../models/coordinator_info.dart'; // Added
// Added
import '../../widgets/progress_indicators.dart'; // Correct import for progress indicator
// Import next screen
import '../../../i18n/gen/strings.g.dart'; // Import Slang - CORRECTED PATH

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
  CoordinatorInfo? _coordinatorInfo;
  Duration? _reservationDuration;
  bool _isLoadingConfig = true;
  String? _configError;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Correct: Call _loadInitialData here
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingConfig = true;
      _configError = null;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final coordinatorInfo = await apiService.getCoordinatorInfo();
      if (!mounted) return;

      setState(() {
        _coordinatorInfo = coordinatorInfo;
        _reservationDuration = Duration(
          seconds: coordinatorInfo.reservationSeconds, // Corrected field access
        );
        _isLoadingConfig = false;
      });
      // Start polling only after config is loaded successfully
      _startStatusCheckTimer();
    } catch (e) {
      if (!mounted) return;
      print(
        "[MakerWaitForBlikScreen] Error loading coordinator info: ${e.toString()}",
      );
      setState(() {
        _isLoadingConfig = false;
        _configError = t.system.errors.loadingCoordinatorConfig;
      });
      // Do not start status check timer if config loading failed
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheckTimer() {
    // Ensure this is called only after _reservationDuration is set
    if (_reservationDuration == null) {
      print(
        "[MakerWaitForBlikScreen] _startStatusCheckTimer called before _reservationDuration is set. Aborting timer start.",
      );
      if (mounted && _configError == null && !_isLoadingConfig) {
        setState(() {
          _configError = t.system.errors.loadingTimeoutConfig;
        });
      }
      return;
    }
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
        _resetToRoleSelection(t.offers.errors.detailsMissing);
      }
      return;
    }

    // Check if reservation time expired locally first
    if (offer.reservedAt != null && _reservationDuration != null) {
      final expiresAt = offer.reservedAt!.add(_reservationDuration!);
      if (DateTime.now().isAfter(expiresAt)) {
        print(
          "[MakerWaitForBlik] Reservation time likely expired locally. Popping back.",
        );
        _statusCheckTimer?.cancel(); // Stop polling
        if (mounted) {
          print(
            "[MakerWaitForBlik] Popping self and pushing MakerConfirmPaymentScreen...",
          );
          context.go('/wait-taker');
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

      var currentStatus = OfferStatus.values.byName(statusString);

      Offer offerToCheck = offer;
      if (offer.status != currentStatus.name) {
        final updatedOfferData = await apiService.getMyActiveOffer(makerId);
        if (updatedOfferData != null) {
          final updatedOffer = Offer.fromJson(updatedOfferData);
          ref.read(activeOfferProvider.notifier).state = updatedOffer;
          offerToCheck = updatedOffer;
          print(
            "[MakerWaitForBlik] Updated activeOfferProvider with status: ${offerToCheck.status}",
          );
          currentStatus = OfferStatus.values.byName(offerToCheck.status);
        } else {
          print(
            "[MakerWaitForBlik] Warning: Failed to fetch updated offer details after status change.",
          );
        }
      }

      final String offerId = offerToCheck.id;

      if (currentStatus == OfferStatus.blikReceived ||
          currentStatus == OfferStatus.blikSentToMaker) {
        print(
          "[MakerWaitForBlik] BLIK received/sent. Fetching code via API...",
        );
        _statusCheckTimer?.cancel();

        try {
          print(
            "[MakerWaitForBlik] Calling getBlikCodeForMaker with offerId: $offerId, makerId: $makerId",
          );
          final blikCode = await apiService.getBlikCodeForMaker(
            offerId,
            makerId,
          );
          print("[MakerWaitForBlik] API returned blikCode: $blikCode");

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
              context.go('/confirm-blik');
            }
          } else {
            print(
              "[MakerWaitForBlik] Error: Status is ${currentStatus.name} but API returned no BLIK code. Resetting.",
            );
            if (mounted) {
              _resetToRoleSelection(t.system.errors.generic); // Generic error
            }
          }
        } catch (e) {
          print("[MakerWaitForBlik] Error calling getBlikCodeForMaker: $e");
          if (mounted) {
            _resetToRoleSelection(t.system.errors.generic); // Generic error
          }
        }
      } else if (currentStatus == OfferStatus.funded) {
        print(
          "[MakerWaitForBlik] Offer reverted to FUNDED (Taker likely timed out). Popping back.",
        );
        _statusCheckTimer?.cancel();
        if (mounted) {
          context.go('/wait-taker');
        }
      } else if (currentStatus == OfferStatus.reserved) {
        print(
          "[MakerWaitForBlik] Still waiting for BLIK (Status: $currentStatus).",
        );
      } else {
        print(
          "[MakerWaitForBlik] Offer in unexpected state ($currentStatus). Resetting.",
        );
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(t.system.errors.generic); // Generic error
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

    if (_isLoadingConfig) {
      return Scaffold(
        appBar: AppBar(title: Text(t.maker.waitForBlik.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_configError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.common.notifications.error),
        ), // Corrected path
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_configError!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: Text(t.common.buttons.retry), // Corrected path
              ),
            ],
          ),
        ),
      );
    }

    if (offer == null ||
        offer.reservedAt == null ||
        _reservationDuration == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.common.notifications.error),
        ), // Corrected path
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.offers.errors.detailsMissing),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goHome,
                child: Text(t.common.buttons.goHome),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.maker.waitForBlik.title),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: t.common.buttons.goHome,
            onPressed: _goHome,
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
                t.maker.waitForBlik.message, // Corrected from offerReserved
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                t
                    .maker
                    .waitForBlik
                    .timeLimit, // Corrected from waitingForTakerBlik
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ReservationProgressIndicator(
                key: ValueKey(
                  'res_timer_${offer.id}_${_reservationDuration!.inSeconds}',
                ),
                reservedAt: offer.reservedAt!,
                maxDuration: _reservationDuration!,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                // Using timeLimitWithSeconds as it seems more appropriate here
                t.maker.waitForBlik.timeLimitWithSeconds(
                  seconds: _reservationDuration!.inSeconds,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // Added missing closing brace for the class
