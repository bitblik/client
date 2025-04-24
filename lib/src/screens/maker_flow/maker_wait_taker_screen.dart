import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/offer.dart'; // For OfferStatus enum
import '../../providers/providers.dart';
import '../../widgets/progress_indicators.dart';

// Renamed class
class MakerWaitTakerScreen extends ConsumerStatefulWidget {
  const MakerWaitTakerScreen({super.key}); // Updated constructor

  @override
  ConsumerState<MakerWaitTakerScreen> createState() =>
      _MakerWaitTakerScreenState();
}

// Renamed state class
class _MakerWaitTakerScreenState extends ConsumerState<MakerWaitTakerScreen> {
  Timer? _statusCheckTimer; // Renamed timer
  bool _isChecking = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    // Delay the first status check until after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if still mounted before starting
        _startStatusCheckTimer(); // Start the timer sequence here
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Use renamed timer
    super.dispose();
  }

  // Modified signature to control immediate check
  void _startStatusCheckTimer({bool checkImmediately = false}) {
    _statusCheckTimer?.cancel();
    print(
      "[MakerWaitTakerScreen] Starting status check sequence (checkImmediately: $checkImmediately)...",
    );
    // Check immediately first time *only if requested*
    if (checkImmediately) {
      _checkOfferStatus(); // Renamed method call
    }
    // Then check periodically
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      // Slightly longer interval maybe?
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isChecking) {
        print("[MakerWaitTakerScreen] Periodic timer initiating status check.");
        await _checkOfferStatus(); // Renamed method call
      } else {
        print(
          "[MakerWaitTakerScreen] Periodic timer fired but check already in progress.",
        );
      }
    });
    print(
      "[MakerWaitTakerScreen] Periodic timer scheduled (ID: ${_statusCheckTimer?.hashCode}).",
    );
  }

  // Renamed method
  Future<void> _checkOfferStatus() async {
    if (_isChecking) return;

    // Use activeOfferProvider to get the current offer details
    final offer = ref.read(activeOfferProvider);
    final paymentHash =
        offer?.holdInvoicePaymentHash; // Get hash from active offer
    final makerId = ref.read(publicKeyProvider).value;

    if (paymentHash == null || makerId == null || offer == null) {
      print(
        "[MakerWaitTakerScreen] Error: Missing offer, payment hash or public key.",
      );
      if (offer == null && mounted) {
        _resetToRoleSelection("Error: Active offer details lost.");
      }
      return;
    }

    _isChecking = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final statusString = await apiService.getOfferStatus(paymentHash);
      print(
        "[MakerWaitTakerScreen] Poll result for $paymentHash: $statusString",
      );

      if (statusString == null) {
        print("[MakerWaitTakerScreen] Warning: Status check returned null.");
        // Added return; finally block will still execute
        return;
      }

      var currentStatus = OfferStatus.values.byName(
        statusString,
      ); // Changed to var

      // Update the active offer provider if the status changed
      if (offer.status != currentStatus.name) {
        final updatedOfferData = await apiService.getMyActiveOffer(makerId);
        if (updatedOfferData != null) {
          final updatedOffer = Offer.fromJson(updatedOfferData);
          ref.read(activeOfferProvider.notifier).state = updatedOffer;
          print(
            "[MakerWaitTakerScreen] Updated activeOfferProvider with status: ${updatedOffer.status}",
          );
          // Re-check the status from the *updated* offer object
          if (updatedOffer.status == OfferStatus.reserved.name) {
            currentStatus =
                OfferStatus.reserved; // Update local status check variable
          }
        } else {
          print(
            "[MakerWaitTakerScreen] Warning: Failed to fetch updated offer details after status change.",
          );
          // Don't attempt local update if fetch failed, rely on next poll
        }
      }

      if (currentStatus == OfferStatus.reserved) {
        print(
          "[MakerWaitTakerScreen] Offer RESERVED. Navigating to wait for BLIK.",
        );
        _statusCheckTimer?.cancel(); // Stop timer before navigating
        if (mounted) {
          // Await the result of the push (which completes when the pushed screen is popped)
          print(
            "[MakerWaitTakerScreen] Navigating to MakerWaitForBlikScreen (awaiting)...",
          );
          context.go('/wait-blik');
          // When back on this screen, check status and restart timer if appropriate
          print("[MakerWaitTakerScreen] Returned from MakerWaitForBlikScreen.");
          if (mounted) {
            final currentOfferState = ref.read(
              activeOfferProvider,
            ); // Check state again
            if (currentOfferState != null &&
                (currentOfferState.status == OfferStatus.funded ||
                    currentOfferState.status == OfferStatus.published)) {
              print(
                "[MakerWaitTakerScreen] Offer is FUNDED/PUBLISHED. Restarting timer.",
              );
              _startStatusCheckTimer(); // Restart the timer here
            } else {
              print(
                "[MakerWaitTakerScreen] Offer status is ${currentOfferState?.status}. Not restarting timer.",
              );
            }
          } else {
            print("[MakerWaitTakerScreen] Widget unmounted after return.");
          }
        }
      } else if (currentStatus == OfferStatus.funded ||
          currentStatus == OfferStatus.published) {
        print(
          "[MakerWaitTakerScreen] Still waiting for Taker (Status: $currentStatus).",
        );
        // Timer continues automatically in the finally block if status hasn't changed
      } else if (currentStatus == OfferStatus.blikReceived ||
          currentStatus == OfferStatus.blikSentToMaker) {
        // Handle case where BLIK is received while still on this screen
        print(
          "[MakerWaitTakerScreen] Offer status became ${currentStatus.name}. Fetching BLIK code and navigating to confirm screen.",
        );
        _statusCheckTimer?.cancel();
        try {
          final String offerId =
              offer.id; // Use offer ID from the start of the check
          final blikCode = await apiService.getBlikCodeForMaker(
            offerId,
            makerId,
          );
          if (blikCode != null && blikCode.isNotEmpty) {
            ref.read(receivedBlikCodeProvider.notifier).state = blikCode;
            if (mounted) {
              context.go('/confirm-blik');
            }
          } else {
            print(
              "[MakerWaitTakerScreen] Error: API returned no BLIK code despite status ${currentStatus.name}. Resetting.",
            );
            if (mounted) {
              _resetToRoleSelection("Error: Failed to retrieve BLIK code.");
            }
          }
        } catch (e) {
          print("[MakerWaitTakerScreen] Error calling getBlikCodeForMaker: $e");
          if (mounted) {
            _resetToRoleSelection(
              "Error retrieving BLIK code: ${e.toString()}",
            );
          }
        }
      } else if (currentStatus == OfferStatus.expired) {
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(
            "Offer is no longer available (Status: ${currentStatus.name}).",
          );
        }
      } else {
        // Handle other unexpected states explicitly
        print(
          "[MakerWaitTakerScreen] Offer in unexpected state ($currentStatus). Resetting.",
        );
        _statusCheckTimer?.cancel();
        if (mounted) {
          _resetToRoleSelection(
            "Offer is no longer available (Status: ${currentStatus.name}).",
          );
        }
      }
    } catch (e) {
      print('[MakerWaitTakerScreen] Error checking offer status: $e');
      // Consider if timer should restart on error or stop
      // _startStatusCheckTimer(); // Optional: restart timer even on error?
    } finally {
      // Ensure _isChecking is reset regardless of outcome
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  // Helper to reset state and go back to role selection
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
        context.go("/");
      }
    });
  }

  // Simple navigation back to root without resetting state
  void _goHome() {
    _statusCheckTimer?.cancel();
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  // Function to handle offer cancellation
  Future<void> _cancelOffer() async {
    final offer = ref.read(activeOfferProvider);
    final makerId = ref.read(publicKeyProvider).value;

    if (offer == null || makerId == null) {
      print("[MakerWaitTakerScreen] Cannot cancel: Missing offer or maker ID.");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorCouldNotIdentifyOffer,
            ),
          ),
        );
      return;
    }
    if (offer.status != OfferStatus.funded.name &&
        offer.status != OfferStatus.published.name) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.offerCannotBeCancelled(offer.status),
            ),
          ),
        );
      return;
    }

    setState(() {
      _isCancelling = true;
    });
    ref.read(errorProvider.notifier).state = null;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.cancelOffer(offer.id, makerId);
      _resetToRoleSelection("Offer cancelled successfully.");
    } catch (e) {
      print("[MakerWaitTakerScreen] Error cancelling offer: $e");
      if (mounted) {
        ref.read(errorProvider.notifier).state = "Failed to cancel offer: $e";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to cancel offer: $e")));
      }
    } finally {
      if (mounted)
        setState(() {
          _isCancelling = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Correct signature: remove WidgetRef ref
    final offer = ref.watch(activeOfferProvider); // Access ref directly

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (offer != null) ...[
              Text(
                AppLocalizations.of(context)!.yourOffer,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                )!.amountSats(offer.amountSats.toString()),
              ),
              Text(
                AppLocalizations.of(context)!.feeSats(offer.feeSats.toString()),
              ),
              Text(
                AppLocalizations.of(
                  context,
                )!.status(offer.status.toUpperCase()),
              ),
              const SizedBox(height: 30),
            ],
            if (offer != null &&
                offer.status == OfferStatus.funded.name &&
                offer.createdAt != null)
              FundedOfferProgressIndicator(
                key: ValueKey('progress_funded_${offer.id}'),
                createdAt: offer.createdAt!,
              ),
            Text(
              AppLocalizations.of(context)!.waitingForTaker,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (offer == null ||
                offer.status != OfferStatus.funded.name ||
                offer.createdAt == null)
              const CircularProgressIndicator(),
            const SizedBox(height: 40),
            Consumer(
              builder: (context, ref, _) {
                final error = ref.watch(errorProvider);
                if (error != null && error.contains("Failed to cancel offer")) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ElevatedButton(
              onPressed:
                  _isCancelling ||
                          (offer != null &&
                              offer.status != OfferStatus.funded.name &&
                              offer.status != OfferStatus.published.name)
                      ? null
                      : _cancelOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child:
                  _isCancelling
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : Text(AppLocalizations.of(context)!.cancelOffer),
            ),
          ],
        ),
      ),
    );
  }
}
