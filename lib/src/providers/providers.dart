import 'dart:async'; // For Stream.periodic

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coordinator_info.dart';
import '../models/offer.dart'; // OfferStatus is in here
// ignore_for_file: depend_on_referenced_packages
import '../services/api_service_nostr.dart';
import '../services/nostr_service.dart'; // Import DiscoveredCoordinator
import '../services/key_service.dart'; // Import KeyService
import '../services/offer_db_service.dart';

final keyServiceProvider = Provider<KeyService>((ref) {
  final service = KeyService();
  return service;
});

final apiServiceProvider = Provider<ApiServiceNostr>((ref) {
  final keyService = ref.read(keyServiceProvider);
  return ApiServiceNostr(keyService);
});

final initializedApiServiceProvider = FutureProvider<ApiServiceNostr>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  await apiService.init();
  return apiService;
});

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
    _ref.read(keyServiceProvider);
    _startDiscovery();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
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
      state = AsyncValue.data(coordinators);

      // Cache coordinator info for all discovered coordinators
      for (final coordinator in coordinators) {
        await apiService.checkCoordinatorHealth(coordinator.pubkey);
      }
      // final healthyCheckedCoordinators = await apiService.coordinatorsStream.first;
      state = AsyncValue.data(apiService.discoveredCoordinators);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _startDiscovery() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.startCoordinatorDiscovery();
      // After starting discovery, refresh the coordinators
      _startPeriodicRefresh();
      state = AsyncValue.loading();
      await _loadCoordinators();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
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
    if (offer.status == 'funded' || offer.status == 'reserved') {
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

  void updateOfferStatus(OfferStatusUpdate update) {
    if (state != null) {
      final updatedOffer = state!.copyWith(
        status: update.status,
        reservedAt: update.reservedAt,
      );
      setActiveOffer(updatedOffer);
    }
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

/// This provider manages the lifecycle of the offer status subscription.
/// It should be initialized once in the app's lifecycle, for example in main.dart,
/// to ensure it's always running and can react to changes in the active offer.
final offerStatusSubscriptionManagerProvider = Provider<void>((ref) {
  StreamSubscription? statusSubscription;

  ref.listen<Offer?>(activeOfferProvider, (previous, current) {
    // If there's an existing subscription, cancel it.
    statusSubscription?.cancel();

    if (current != null) {
      print(
        "[SubscriptionManager] Active offer changed to ${current.id}. Starting new status subscription.",
      );
      final apiService = ref.read(apiServiceProvider);
      final activeOfferNotifier = ref.read(activeOfferProvider.notifier);

      // Start the subscription for the new active offer.
      apiService.startOfferStatusSubscription(
        current.coordinatorPubkey,
        current.takerPubkey ?? current.makerPubkey,
      );

      // Listen to the stream for status updates.
      statusSubscription = apiService.offerStatusStream.listen((statusUpdate) {
        // Ensure the update is for the current active offer.
        if (statusUpdate.offerId == current.id ||
            statusUpdate.paymentHash == current.holdInvoicePaymentHash) {
          OfferStatus? newStatus;
          try {
            newStatus = OfferStatus.values.byName(statusUpdate.status);
          } catch (e) {
            print("Error parsing status string '${statusUpdate.status}': $e");
          }

          if (newStatus != null) {
            print(
              "Offer ${current.id} status updated to: $newStatus. Updating active offer provider.",
            );
            activeOfferNotifier.updateOfferStatus(statusUpdate);
          }
        }
      });
    } else {
      print(
        "[SubscriptionManager] Active offer cleared. Subscription stopped.",
      );
    }
  }, fireImmediately: true); // fireImmediately to handle initial state
});

// Provider for fetching a single offer's details.
// It's a family provider because it depends on an external parameter (the offer ID).
final offerDetailsProvider = FutureProvider.family<Offer?, String>((
  ref,
  offerId,
) async {
  // First, ensure that the API service is fully initialized.
  final apiService = await ref.watch(initializedApiServiceProvider.future);
  // Trigger coordinator discovery
  ref.watch(discoveredCoordinatorsProvider);
  // Then, fetch the specific offer.
  return apiService.getOffer(offerId);
});

// Provider for fetching successful offers statistics
final successfulOffersStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return {}; //apiService.getSuccessfulOffersStats();
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
