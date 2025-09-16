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
      final offer = ref.read(activeOfferProvider);
      final coordinatorPubkey = offer?.coordinatorPubkey;
      if (coordinatorPubkey == null)
        throw Exception('No coordinator pubkey for active offer');
      final coordinatorInfo = apiService.getCoordinatorInfoByPubkey(
        coordinatorPubkey,
      );
      if (coordinatorInfo == null)
        throw Exception('No coordinator info found for pubkey');
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
        "[MakerWaitForBlikScreen] Error loading coordinator info:  [1m${e.toString()} [0m",
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
    // No longer need timer - will use subscription instead
  }

  void _handleStatusUpdate(OfferStatus? status) async {
    if (status == null) return;

    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;
    final coordinatorPubkey = offer?.coordinatorPubkey;

    if (offer == null || makerId == null || coordinatorPubkey == null) {
      print(
        "[MakerWaitForBlik] Error: Missing offer, public key or coordinator pubkey.",
      );
      return;
    }

    print("[MakerWaitForBlik] Status update received: $status");

    if (status == OfferStatus.blikReceived ||
        status == OfferStatus.blikSentToMaker) {
      print("[MakerWaitForBlik] BLIK received/sent. Fetching code via API...");

      try {
        final apiService = ref.read(apiServiceProvider);
        final blikCode = await apiService.getBlikCodeForMaker(
          offer.id,
          makerId,
          coordinatorPubkey,
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
            "[MakerWaitForBlik] Error: Status is $status but API returned no BLIK code. Resetting.",
          );
          if (mounted) {
            _resetToRoleSelection(t.system.errors.generic);
          }
        }
      } catch (e) {
        print("[MakerWaitForBlik] Error calling getBlikCodeForMaker: $e");
        if (mounted) {
          _resetToRoleSelection(t.system.errors.generic);
        }
      }
    } else if (status == OfferStatus.funded) {
      print(
        "[MakerWaitForBlik] Offer reverted to FUNDED (Taker likely timed out). Popping back.",
      );
      if (mounted) {
        context.go('/wait-taker');
      }
    } else if (status == OfferStatus.reserved) {
      print("[MakerWaitForBlik] Still waiting for BLIK (Status: $status).");
    } else {
      print(
        "[MakerWaitForBlik] Offer in unexpected state ($status). Resetting.",
      );
      if (mounted) {
        _resetToRoleSelection(t.system.errors.generic);
      }
    }
  }

  Future<void> _resetToRoleSelection(String message) async {
    await ref.read(activeOfferProvider.notifier).setActiveOffer(null);
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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the active offer to get the latest data
    final offer = ref.watch(activeOfferProvider);

    // Listen to the active offer provider for status changes
    ref.listen<Offer?>(activeOfferProvider, (previous, next) {
      if (next != null) {
        // Handle status update only if the status has actually changed
        if (previous == null || previous.status != next.status) {
          _handleStatusUpdate(next.statusEnum);
        }
      }
    });

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
