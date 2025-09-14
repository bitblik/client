import 'dart:async'; // For Stream.periodic

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coordinator_info.dart';
import '../models/offer.dart'; // OfferStatus is in here
// ignore_for_file: depend_on_referenced_packages
import '../services/api_service_nostr.dart';
import '../services/nostr_service.dart'; // Import DiscoveredCoordinator
import '../services/key_service.dart'; // Import KeyService
import '../services/offer_db_service.dart';
// Remove import of main.dart

// Provider for the KeyService instance (needed by ApiServiceNostr)
final keyServiceProvider = Provider<KeyService>((ref) {
  final service = KeyService();
  return service;
});

// Provider for the ApiServiceNostr instance
final apiServiceProvider = Provider<ApiServiceNostr>((ref) {
  final keyService = ref.watch(keyServiceProvider);
  return ApiServiceNostr(keyService);
});

// Provider that initializes the API service
final initializedApiServiceProvider = FutureProvider<ApiServiceNostr>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  await apiService.init();
  return apiService;
});

/// Provider for discovered coordinators with refresh capability
// NOTE: The DiscoveredCoordinator model now includes 'responsive' bool.
// Unresponsive coordinators will be emitted in the state list and should be handled in the UI (greyed out, unselectable, show warning)
final discoveredCoordinatorsProvider = StateNotifierProvider<
  DiscoveredCoordinatorsNotifier,
  AsyncValue<List<DiscoveredCoordinator>>
>((ref) => DiscoveredCoordinatorsNotifier(ref));

class DiscoveredCoordinatorsNotifier
    extends StateNotifier<AsyncValue<List<DiscoveredCoordinator>>> {
  final Ref _ref;
  Timer? _refreshTimer;

  DiscoveredCoordinatorsNotifier(this._ref)
    : super(const AsyncValue.loading()) {
    _loadCoordinators();
    _startDiscovery();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadCoordinators();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCoordinators() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final coordinators = apiService.discoveredCoordinators;

      // Cache coordinator info for all discovered coordinators
      for (final coordinator in coordinators) {
        final coordinatorInfo = coordinator.toCoordinatorInfo();
        apiService.cacheCoordinatorInfo(coordinator.pubkey, coordinatorInfo);
      }

      state = AsyncValue.data(coordinators);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _startDiscovery() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.startCoordinatorDiscovery();
      // After starting discovery, refresh the coordinators
      await _loadCoordinators();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await _loadCoordinators();
  }
}

/// Provider to start coordinator discovery
final coordinatorDiscoveryProvider = FutureProvider<void>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  await apiService.startCoordinatorDiscovery();
});

/// Provider for coordinator info by pubkey
final coordinatorInfoByPubkeyProvider =
    Provider.family<CoordinatorInfo?, String>((ref, pubkey) {
      final apiService = ref.watch(apiServiceProvider);
      return apiService.getCoordinatorInfoByPubkey(pubkey);
    });

// Only initialize the Nostr offer subscription once (global for the app lifetime)
final offersSubscriptionInitializer = FutureProvider<void>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  await apiService.startOfferSubscription();
});

final offers = <Offer>[];

// Provider for real-time list of available offers from Nostr subscription
final availableOffersProvider = StreamProvider<List<Offer>>((ref) async* {
  // Depend on single global initializer
  await ref.watch(offersSubscriptionInitializer.future);
  final apiService = ref.watch(apiServiceProvider);
  await for (final offer in apiService.offersStream) {
    offers.removeWhere((o) => o.id == offer.id);
    if (offer.status == 'funded') {
      offers.add(offer);
    }
    yield List<Offer>.from(offers.reversed);
  }
});

// Provider to hold the currently selected/active offer (if any)
final activeOfferProvider = StateNotifierProvider<ActiveOfferNotifier, Offer?>(
  (ref) => ActiveOfferNotifier(),
);

class ActiveOfferNotifier extends StateNotifier<Offer?> {
  ActiveOfferNotifier() : super(null) {
    _loadActiveOffer();
  }

  Future<void> _loadActiveOffer() async {
    final offer = await OfferDbService().getActiveOffer();
    state = offer;
  }

  Future<void> setActiveOffer(Offer? offer) async {
    if (offer != null) {
      print('[ActiveOfferNotifier] Setting active offer: ${offer.toJson()}');
      await OfferDbService().upsertActiveOffer(offer);
    } else {
      print('[ActiveOfferNotifier] Clearing active offer');
      await OfferDbService().deleteActiveOffer();
    }
    state = offer;
  }

  /// Force a database reset (useful for development when schema changes are made)
  Future<void> resetDatabase() async {
    await OfferDbService().resetDatabase();
    state = null;
  }
}

/// Provider to expose the stored Lightning Address
final lightningAddressProvider = FutureProvider<String?>((ref) async {
  final keyService = ref.watch(keyServiceProvider);
  // Ensure KeyService is initialized (which loads keys) before getting address
  await keyService.init();
  return keyService.getLightningAddress();
});

/// Provider for finished (takerPaid, <24h) offers for the current user (taker)
final finishedOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final publicKey = await ref.watch(publicKeyProvider.future);
  if (publicKey == null) return [];
  final apiService = ref.watch(apiServiceProvider);
  final offersData = await apiService.getMyFinishedOffers(publicKey);
  final now = DateTime.now().toUtc();

  return offersData.where((offer) {
    if (offer.status == 'takerPaid') {
      final paidAt = offer.takerPaidAt;
      return paidAt != null && now.difference(paidAt.toUtc()).inHours < 24;
    }
    return false;
  }).toList();
});

// You might add more providers here as needed for:
// - Taker's submitted BLIK code
// - Taker's Lightning Address
// - Current step in the Maker/Taker flow
// - Timers (e.g., for reservation expiry) - requires more complex state logic

// Provider that polls the user's active offer status every second
// final pollingMyActiveOfferProvider = StreamProvider.autoDispose.family<
//   Offer?, // Yields the Offer object or null
//   String // Takes userPubkey as parameter
// >((ref, userPubkey) async* {
//   final apiService = ref.watch(apiServiceProvider);
//
//   Offer? parseOfferData(Map<String, dynamic>? offerData) {
//     if (offerData == null) return null;
//     try {
//       DateTime? parseOptionalDateTime(String? dateString) {
//         return dateString != null ? DateTime.parse(dateString) : null;
//       }
//
//       return Offer(
//         id: offerData['id'] as String,
//         amountSats: offerData['amount_sats'] as int,
//         makerFees: offerData['maker_fees'] as int,
//         fiatAmount: offerData['fiat_amount'] ?? 0,
//         fiatCurrency: offerData['fiat_currency'] ?? '',
//         status: offerData['status'] as String,
//         createdAt: DateTime.parse(offerData['created_at'] as String),
//         makerPubkey: offerData['maker_pubkey'] as String? ?? '',
//         takerPubkey: offerData['taker_pubkey'] as String?,
//         takerLightningAddress: offerData['taker_lightning_address'] as String?,
//         reservedAt: parseOptionalDateTime(offerData['reserved_at'] as String?),
//         blikReceivedAt: parseOptionalDateTime(
//           offerData['blik_received_at'] as String?,
//         ),
//         holdInvoicePaymentHash:
//             offerData['hold_invoice_payment_hash'] as String?,
//         // Add other fields if needed from the API response
//       );
//     } catch (e) {
//       print("Error parsing active offer data during polling: $e");
//       print("Received data: $offerData");
//       return null;
//     }
//   }
//
//   // Initial fetch
//   try {
//     final initialOfferData = await apiService.getMyActiveOffer(userPubkey);
//     final initialOffer = parseOfferData(initialOfferData);
//     yield initialOffer;
//     if (initialOffer == null) {
//       print("No active offer found initially for $userPubkey.");
//       // Keep polling even if no initial offer, user might create/take one
//     }
//   } catch (e) {
//     print("Error fetching initial active offer for $userPubkey: $e");
//     yield null; // Yield null on error
//   }
//
//   // Periodic fetch every second
//   await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
//     try {
//       final currentOfferData = await apiService.getMyActiveOffer(userPubkey);
//       final currentOffer = parseOfferData(currentOfferData);
//       yield currentOffer;
//
//       // Stop polling ONLY if the offer reaches a *final* state for the TAKER flow
//       // We might want to keep polling if it's just 'funded' or 'reserved'
//       if (currentOffer != null &&
//           (currentOffer.status == OfferStatus.takerPaid.name ||
//               currentOffer.status == OfferStatus.takerPaymentFailed.name ||
//               currentOffer.status == OfferStatus.expired.name ||
//               currentOffer.status == OfferStatus.cancelled.name)) {
//         print(
//           "Offer ${currentOffer.id} reached final state: ${currentOffer.status}. Stopping poll for $userPubkey.",
//         );
//         break; // Exit the stream loop
//       }
//       // If currentOffer is null, it means no active offer, keep polling
//     } catch (e) {
//       print("Error polling active offer for $userPubkey: $e");
//       // Decide how to handle polling errors, e.g., yield last known state or null
//       // For now, we yield null and stop, but could keep polling
//       yield null;
//       break;
//     }
//   }
// });

/// Provider that listens for offer status updates via Nostr subscription
final offerStatusSubscriptionProvider = StreamProvider.autoDispose.family<
  OfferStatus?, // Yields the OfferStatus enum or null
  ({
    String paymentHash,
    String coordinatorPubKey,
    String userPubkey,
  }) // Takes paymentHash, coordinatorPubKey, and userPubkey as parameters
>((ref, params) async* {
  final apiService = ref.watch(apiServiceProvider);
  final paymentHash = params.paymentHash;
  final coordinatorPubKey = params.coordinatorPubKey;
  final userPubkey = params.userPubkey;

  OfferStatus? parseStatus(String? statusString) {
    if (statusString == null) return null;
    try {
      return OfferStatus.values.byName(statusString);
    } catch (e) {
      print("Error parsing status string '$statusString': $e");
      return null;
    }
  }

  // Start the subscription
  await apiService.startOfferStatusSubscription(coordinatorPubKey, userPubkey);

  // Listen for status updates via Nostr subscription
  await for (final statusUpdate in apiService.offerStatusStream) {
    // Only process updates for the specific payment hash
    if (statusUpdate.paymentHash == paymentHash) {
      final status = parseStatus(statusUpdate.status);
      yield status;

      // Stop listening on final states
      if (status == OfferStatus.takerPaid ||
          status == OfferStatus.takerPaymentFailed ||
          status == OfferStatus.expired ||
          status == OfferStatus.cancelled) {
        print(
          "Offer $paymentHash reached final state: $status. Stopping status subscription.",
        );
        break;
      }
    }
  }
});

// offerDetailsProvider REMOVED as per user feedback

// Provider for fetching successful offers statistics
final successfulOffersStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return {};//apiService.getSuccessfulOffersStats();
});

// Provider to expose the public key hex.
final publicKeyProvider = FutureProvider<String?>((ref) async {
  final keyService = ref.watch(keyServiceProvider);
  await keyService.init(); // Ensure KeyService is initialized
  return keyService.publicKeyHex; // Return the public key
});

// Provider to hold the generated hold invoice for the Maker
final holdInvoiceProvider = StateProvider<String?>((ref) => null);

// Provider to hold the payment hash for the Maker's offer
final paymentHashProvider = StateProvider<String?>((ref) => null);

// Provider to manage the current role (Maker/Taker) or view state
// enum AppRole { none, maker, taker }

// final appRoleProvider = StateProvider<AppRole>((ref) => AppRole.none);

// Provider to manage loading states for specific actions
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider to hold the BLIK code received by the Maker
final receivedBlikCodeProvider = StateProvider<String?>((ref) => null);

// Provider to hold error messages for display in the UI
final errorProvider = StateProvider<String?>((ref) => null);
