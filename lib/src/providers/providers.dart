import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/key_service.dart'; // Import KeyService
import '../models/offer.dart';
import '../services/sound_service.dart'; // Import SoundService
// Remove import of main.dart

// Provider for the ApiService instance
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider for the SoundService instance
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(
    () => service.dispose(),
  ); // Dispose the player when provider is disposed
  return service;
});

// Provider for fetching the list of available offers
// Using FutureProvider to handle async loading and errors
final availableOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.listAvailableOffers();
});

// Provider to hold the currently selected/active offer (if any)
// Using StateProvider as it will change based on user interaction
final activeOfferProvider = StateProvider<Offer?>((ref) => null);

// Provider to hold the generated hold invoice for the Maker
final holdInvoiceProvider = StateProvider<String?>((ref) => null);

// Provider to hold the payment hash for the Maker's offer
final paymentHashProvider = StateProvider<String?>((ref) => null);

// Provider to manage the current role (Maker/Taker) or view state
enum AppRole { none, maker, taker }

final appRoleProvider = StateProvider<AppRole>((ref) => AppRole.none);

// Provider to manage loading states for specific actions
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Provider to hold the BLIK code received by the Maker
final receivedBlikCodeProvider = StateProvider<String?>((ref) => null);

// Provider to hold error messages for display in the UI
final errorProvider = StateProvider<String?>((ref) => null);

// --- Key Service Providers ---

// Provider that creates and initializes the KeyService instance
final keyServiceProvider = Provider<KeyService>((ref) {
  final service = KeyService();
  return service;
});

// Provider to expose the public key hex.
final publicKeyProvider = FutureProvider<String?>((ref) async {
  final keyService = ref.watch(keyServiceProvider);
  await keyService.init(); // Ensure KeyService is initialized
  return keyService.publicKeyHex; // Return the public key
});

// Provider to check for an existing active offer for the current user on startup
final initialActiveOfferProvider = FutureProvider<Offer?>((ref) async {
  final publicKey = await ref.watch(publicKeyProvider.future);
  if (publicKey == null) {
    return null; // No public key, no active offer
  }
  final apiService = ref.watch(apiServiceProvider);
  final offerData = await apiService.getMyActiveOffer(publicKey);

  if (offerData != null) {
    // print("[DEBUG] my-active-offer response: $offerData");
    try {
      // Helper to safely parse DateTime directly inside constructor call
      DateTime? parseOptionalDateTime(String? dateString) {
        return dateString != null ? DateTime.parse(dateString) : null;
      }

      // Pass all fields directly to the constructor
      return Offer(
        id: offerData['id'] as String,
        amountSats: offerData['amount_sats'] as int,
        makerFees: offerData['maker_fees'] as int, // Renamed key and field
        fiatAmount: offerData['fiat_amount'] ?? 0,
        fiatCurrency: offerData['fiat_currency'] ?? '',
        status: offerData['status'] as String,
        createdAt: DateTime.parse(offerData['created_at'] as String),
        makerPubkey:
            offerData['maker_pubkey'] as String? ??
            '', // Assuming non-null from backend for active offers
        takerPubkey: offerData['taker_pubkey'] as String?,
        takerLightningAddress: offerData['taker_lightning_address'] as String?,
        reservedAt: parseOptionalDateTime(offerData['reserved_at'] as String?),
        blikReceivedAt: parseOptionalDateTime(
          offerData['blik_received_at'] as String?,
        ),
        holdInvoicePaymentHash:
            offerData['hold_invoice_payment_hash'] as String?,
      );
    } catch (e) {
      print("Error parsing active offer data: $e");
      print("Received data: $offerData"); // Log received data on error
      return null;
    }
  }
  return null;
});

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
