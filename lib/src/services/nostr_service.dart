import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:logger/logger.dart' as lib_logger;
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip44/nip44.dart';
import 'package:ndk_rust_verifier/data_layer/repositories/verifiers/rust_event_verifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../models/coordinator_info.dart';
import '../models/offer.dart';
import 'key_service.dart';

/// Request/Response models for Nostr RPC communication
class NostrRequest {
  final String method;
  final Map<String, dynamic> params;
  final String? id;

  NostrRequest({required this.method, required this.params, this.id});

  Map<String, dynamic> toJson() => {
    'method': method,
    'params': params,
    if (id != null) 'id': id,
  };
}

class NostrResponse {
  final String? id;
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? error;

  NostrResponse({this.id, this.result, this.error});

  factory NostrResponse.fromJson(Map<String, dynamic> json) {
    return NostrResponse(
      id: json['id'],
      result: json['result'],
      error: json['error'],
    );
  }

  bool get isSuccess => error == null;
}

/// Discovered coordinator information
class DiscoveredCoordinator {
  final String pubkey;
  final String name;
  final String? icon;
  final int minAmountSats;
  final int maxAmountSats;
  final double makerFee;
  final double takerFee;
  final int reservationSeconds;
  final List<String> currencies;
  final String version;
  final DateTime lastSeen;
  bool? responsive;

  DiscoveredCoordinator({
    required this.pubkey,
    required this.name,
    this.icon,
    required this.minAmountSats,
    required this.maxAmountSats,
    required this.makerFee,
    required this.takerFee,
    required this.reservationSeconds,
    required this.currencies,
    required this.version,
    required this.lastSeen,
    this.responsive,
  });

  factory DiscoveredCoordinator.fromNostrEvent(Nip01Event event) {
    final tags = Map<String, String>.fromEntries(
      event.tags
          .where((tag) => tag.length >= 2)
          .map((tag) => MapEntry(tag[0], tag[1])),
    );

    return DiscoveredCoordinator(
      pubkey: event.pubKey,
      name: tags['name'] ?? 'Unknown Coordinator',
      icon: tags['icon'],
      minAmountSats: int.tryParse(tags['min_amount_sats'] ?? '0') ?? 0,
      maxAmountSats: int.tryParse(tags['max_amount_sats'] ?? '0') ?? 0,
      makerFee: double.tryParse(tags['maker_fee'] ?? '0') ?? 0.0,
      takerFee: double.tryParse(tags['taker_fee'] ?? '0') ?? 0.0,
      reservationSeconds: int.tryParse(tags['reservation_seconds'] ?? '0') ?? 0,
      currencies:
          (tags['currencies'] ?? '')
              .split(',')
              .where((c) => c.isNotEmpty)
              .toList(),
      version: tags['version'] ?? '',
      lastSeen: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
      responsive: null,
    );
  }

  CoordinatorInfo toCoordinatorInfo() {
    return CoordinatorInfo(
      name: name,
      icon: icon,
      minAmountSats: minAmountSats,
      maxAmountSats: maxAmountSats,
      makerFee: makerFee,
      takerFee: takerFee,
      reservationSeconds: reservationSeconds,
      currencies: currencies,
      nostrNpub: pubkey,
      // Use the pubkey as nostrNpub
      version: version,
    );
  }
}

/// Service for Nostr-based communication with coordinators
class NostrService {
  static const String _selectedCoordinatorKey = 'selected_coordinator_pubkey';
  static const String _relayUrlsKey = 'relay_urls';

  static const List<String> _defaultRelayUrls = [
    'wss://relay.damus.io',
    'wss://relay.primal.net',
    'wss://relay.mostro.network',
  ];

  // Event kinds (matching coordinator)
  static const int KIND_COORDINATOR_INFO = 15125;
  static const int KIND_COORDINATOR_REQUEST = 25195;
  static const int KIND_COORDINATOR_RESPONSE = 25196;
  static const int KIND_OFFER_STATUS_UPDATE = 25197;
  static const int KIND_OFFER = 38383;

  final KeyService _keyService;
  Ndk? _ndk;
  Bip340EventSigner? _clientSigner;
  final Map<String, Completer<NostrResponse>> _pendingRequests = {};
  final Random _random = Random();

  List<String> _relayUrls = [];

  NdkResponse? _responseSubscription;
  NdkResponse? _offerStatusSubscription;
  NdkResponse? _offerSubscription;

  bool _isInitialized = false;

  // Discovered coordinators
  final Map<String, DiscoveredCoordinator> _discoveredCoordinators = {};
  final StreamController<OfferStatusUpdate> _offerStatusController =
      StreamController<OfferStatusUpdate>.broadcast();
  late StreamController<Offer> _offerStreamController;

  // Coordinator info cache by pubkey
  final Map<String, CoordinatorInfo> _coordinatorInfoCache = {};

  List<String> kWhitelistCoordinatorPubKeys = [
    "c6e5e031989223dd63e6ed49f0905a19a92ed86e0754721d6071133a9340bf7e",
  ];

  NostrService(this._keyService) {
    _offerStreamController = StreamController<Offer>.broadcast();
  }

  /// Initialize the Nostr service
  Future<void> init() async {
    if (_isInitialized) return;

    await _loadConfiguration();
    await _initializeNdk();
    await _subscribeToResponses();

    _isInitialized = true;
    print('✅ NostrService initialized');
  }

  /// Load configuration from SharedPreferences
  Future<void> _loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();

    _relayUrls =
        prefs.getStringList(_relayUrlsKey) ?? List.from(_defaultRelayUrls);

    print('📡 Using relays: $_relayUrls');
  }

  /// Initialize NDK and connect to relays
  Future<void> _initializeNdk() async {
    // Destroy existing NDK instance if it exists
    if (_ndk != null) {
      try {
        await _ndk!.destroy();
        print('🔄 Destroyed previous NDK instance');
      } catch (e) {
        print('⚠️ Error destroying previous NDK instance: $e');
      }
    }

    // Initialize NDK with bootstrap relays config
    _ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: rustEventVerifier,//Bip340EventVerifier(),
        bootstrapRelays: _relayUrls,
        logLevel: lib_logger.Level.trace,
      ),
    );

    print(
      '🔑 Client signer initialized with pubkey: ${_keyService.publicKeyHex}',
    );

    // Wait for NDK to actually connect to at least one relay
    print('⏳ Waiting for NDK to connect to relays...');

    // Wait up to 10 seconds for connection
    bool connected = false;
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Check if any relays are connected (this is a simple heuristic)
      // In a real implementation, you'd check NDK's connection status
      // For now, we'll just wait a reasonable amount of time
      if (i >= 3) { // Wait at least 2 seconds
        connected = true;
        break;
      }
    }

    if (connected) {
      print('✅ NDK connection wait completed');
    } else {
      print('⚠️ NDK connection timeout - proceeding anyway');
    }
  }

  /// Subscribe to response events from coordinator
  Future<void> _subscribeToResponses() async {
    if (_keyService.publicKeyHex == null) {
      throw Exception('KeyService not initialized');
    }

    int since = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final filter = Filter(
      kinds: [KIND_COORDINATOR_RESPONSE],
      pTags: [_keyService.publicKeyHex!], // Events tagged to our pubkey
      since: since,
    );

    _responseSubscription = _ndk!.requests.subscription(
      name: "client-responses",
      filters: [filter],
    );

    _responseSubscription!.stream.listen(_handleResponseEvent);
    print('👂 Subscribed to coordinator responses');
  }

  /// Handle incoming response events
  void _handleResponseEvent(Nip01Event event) async {
    try {
      print('📨 Received response event: ${event.id} from ${event.pubKey}');

      // Decrypt the content using NIP-44
      final decryptedContent = await Nip44.decryptMessage(
        event.content,
        _keyService.privateKeyHex!,
        event.pubKey,
      );

      print('🔓 Decrypted response: $decryptedContent');

      final responseData = jsonDecode(decryptedContent) as Map<String, dynamic>;
      final response = NostrResponse.fromJson(responseData);

      // Complete the pending request if ID matches
      if (response.id != null && _pendingRequests.containsKey(response.id)) {
        final completer = _pendingRequests.remove(response.id);
        completer?.complete(response);
        print('✅ Completed request: ${response.id}');
      } else {
        print('⚠️ No matching pending request for response ID: ${response.id}');
      }
    } catch (e) {
      print('❌ Error handling response event: $e');
      print('🔑 Current pubkey: ${_keyService.publicKeyHex}');
      print('📨 Event from: ${event.pubKey}');
    }
  }

  /// Send a request to the coordinator and wait for response
  Future<NostrResponse> sendRequest(
    NostrRequest request,
    String coordinatorPubkey,
  ) async {
    if (!_isInitialized) {
      await init();
    }
    if (_keyService.privateKeyHex == null) {
      throw Exception('KeyService not initialized');
    }
    // Initialize client signer with existing keys
    _clientSigner = Bip340EventSigner(
      privateKey: _keyService.privateKeyHex!,
      publicKey: _keyService.publicKeyHex!,
    );

    final requestId = request.id ?? _generateRequestId();
    final requestWithId = NostrRequest(
      method: request.method,
      params: request.params,
      id: requestId,
    );

    // Create completer for response
    final completer = Completer<NostrResponse>();
    _pendingRequests[requestId] = completer;

    try {
      // Encrypt the request content using NIP-44
      final encryptedContent = await Nip44.encryptMessage(
        jsonEncode(requestWithId.toJson()),
        _keyService.privateKeyHex!,
        coordinatorPubkey,
      );

      // Create and sign the event
      final event = Nip01Event(
        kind: KIND_COORDINATOR_REQUEST,
        pubKey: _keyService.publicKeyHex!,
        content: encryptedContent,
        tags:
            [
              ['p', coordinatorPubkey], // Tag coordinator
            ].map((tag) => tag.map((t) => t.toString()).toList()).toList(),
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      // Sign the event
      await _clientSigner!.sign(event);

      // Publish the event
      _ndk!.broadcast.broadcast(nostrEvent: event);

      print(
        '📤 Sent request: ${request.method} (ID: $requestId) to $coordinatorPubkey',
      );

      // Wait for response with timeout
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw TimeoutException(
            'Request timed out',
            const Duration(seconds: 5),
          );
        },
      );
    } catch (e) {
      _pendingRequests.remove(requestId);
      rethrow;
    }
  }

  /// Generate a random request ID
  String _generateRequestId() {
    return _random.nextInt(999999).toString().padLeft(6, '0');
  }

  /// Helper method to handle response and throw exceptions on error
  T _handleResponse<T>(
    NostrResponse response,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (!response.isSuccess) {
      final error = response.error;
      final errorMessage = error?['message'] ?? 'Unknown error';
      final errorCode = error?['code'] ?? 'UNKNOWN';
      throw NostrException(errorMessage, code: errorCode);
    }

    if (response.result == null) {
      throw NostrException('No result in response');
    }

    return parser(response.result!);
  }

  // --- API Methods (matching original ApiService) ---

  /// POST /initiate-offer (fiat version)
  Future<Map<String, dynamic>> initiateOfferFiat({
    required double fiatAmount,
    required String makerId,
    required String coordinatorPubkey,
  }) async {
    final request = NostrRequest(
      method: 'initiate_offer',
      params: {'fiat_amount': fiatAmount, 'maker_id': makerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    return _handleResponse(response, (result) => result);
  }

  /// GET BTC/PLN rate from external sources (unchanged - not using coordinator)
  Future<double> getBtcPlnRate() async {
    // This method should remain using HTTP requests to external APIs
    // as it doesn't need to go through the coordinator
    throw UnimplementedError(
      'This method should use the original HTTP implementation for external APIs',
    );
  }

  /// Get a stream of all live offers published (subscribe before listening!)
  Stream<Offer> get offersStream => _offerStreamController.stream;

  /// Start listening for offers (subscribe to event kind 38383 from all coordinators)
  Future<void> startOfferSubscription() async {
    if (!_isInitialized) {
      await init();
    }

    // Unsubscribe previous subscription, if any
    if (_offerSubscription != null) {
      await _ndk!.requests.closeSubscription(_offerSubscription!.requestId);
    }
    final filter = Filter(
      kinds: [KIND_OFFER],
      tags: {
        "#f": ["PLN"],
        //        "#s": ['pending'],
        "#y": ["Bitblik"],
        // "#pm": ["BLIK"],
      },
      since:
          DateTime.now()
              .subtract(const Duration(hours: 2))
              .millisecondsSinceEpoch ~/
          1000,
    );
    _offerSubscription = _ndk!.requests.subscription(
      name: "offers-stream",
      filters: [filter],
    );
    _offerSubscription!.stream.listen(_handleOfferEvent);
    print('🔎 Started offers subscription');
  }

  void _handleOfferEvent(Nip01Event event) {
    try {
      final offer = _mapEventToOffer(event);
      _offerStreamController.add(offer);
    } catch (e) {
      print('❌ Error parsing offer event: $e');
    }
  }

  Offer _mapEventToOffer(Nip01Event event) {
    // Map event.tags and content to Offer
    // Most data is in tags according to your coordinator event logic
    final tagMap = <String, String>{};
    for (final t in event.tags) {
      if (t.length >= 2) tagMap[t[0]] = t[1];
    }
    // Build Offer (fallback/default when fields missing!)
    final offer = Offer(
      id: tagMap['d'] ?? event.id,
      amountSats: int.tryParse(tagMap['amt'] ?? '0') ?? 0,
      makerFees: int.tryParse(tagMap['maker_fees'] ?? '0') ?? 0,
      fiatAmount: double.tryParse(tagMap['fa'] ?? '0') ?? 0.0,
      fiatCurrency: tagMap['f'] ?? 'PLN',
      status:
          (_mapOfferStatusToNip69Status(tagMap['s'] ?? 'pending') ??
                  OfferStatus.funded)
              .name,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
      makerPubkey: tagMap['maker'] ?? event.pubKey,
      coordinatorPubkey: tagMap['p'] ?? event.pubKey,
      // or from context
      takerPubkey: tagMap['taker'],
      reservedAt: null,
      blikReceivedAt: null,
      blikCode: null,
      holdInvoicePaymentHash: tagMap['pmt_hash'],
      holdInvoice: tagMap['hold_invoice'],
      takerLightningAddress: tagMap['taker_ln'],
      takerInvoice: tagMap['taker_inv'],
      holdInvoicePreimage: tagMap['preimage'],
      updatedAt: null,
      makerConfirmedAt: null,
      settledAt: null,
      takerPaidAt: null,
      takerFees: int.tryParse(tagMap['taker_fees'] ?? '0'),
    );
    return offer;
  }

  /// Map internal offer status to NIP-69 status
  OfferStatus? _mapOfferStatusToNip69Status(String status) {
    switch (status) {
      case 'pending':
        return OfferStatus.funded;
      case 'in-progress':
        return OfferStatus.reserved;
      case 'success':
        return OfferStatus.takerPaid;
      case 'canceled':
        return OfferStatus.cancelled;
      case 'dispute':
        return OfferStatus.conflict;
      default:
        return null;
    }
  }

  /// Stop the live offer subscription
  Future<void> stopOfferSubscription() async {
    if (_offerSubscription != null) {
      await _ndk!.requests.closeSubscription(_offerSubscription!.requestId);
      _offerSubscription = null;
    }
    await _offerStreamController.close();
    _offerStreamController =
        StreamController<Offer>.broadcast(); // so can restart
  }

  /// GET /offers/{offerId}
  Future<Offer?> getOffer(String offerId) async {
    if (!_isInitialized) {
      await init();
    }

    final filter = Filter(kinds: [KIND_OFFER], dTags: [offerId], limit: 1);

    // Use query for a one-time fetch.
    final response = _ndk!.requests.query(filters: [filter], cacheRead: false);
    final events = await response.stream.toList();

    if (events.isEmpty) {
      return null;
    }

    return _mapEventToOffer(events.first);
  }

  /// POST /offers/{offerId}/reserve
  Future<DateTime?> reserveOffer(
    String offerId,
    String takerId,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'reserve_offer',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    return _handleResponse(response, (result) {
      final timestamp = result['reserved_at'] as int?;
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    });
  }

  /// POST /offers/{offerId}/blik
  Future<void> submitBlikCode({
    required String offerId,
    required String takerId,
    required String blikCode,
    required String takerLightningAddress,
    required String coordinatorPubkey,
  }) async {
    final request = NostrRequest(
      method: 'submit_blik',
      params: {
        'offer_id': offerId,
        'blik_code': blikCode,
        'taker_lightning_address': takerLightningAddress,
      },
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// GET /offers/{offerId}/blik
  Future<String?> getBlikCodeForMaker(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'get_blik',
      params: {'offer_id': offerId},
    );

    try {
      final response = await sendRequest(request, coordinatorPubkey);
      return _handleResponse(
        response,
        (result) => result['blik_code'] as String?,
      );
    } catch (e) {
      if (e is NostrException && e.message.contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  /// POST /offers/{offerId}/confirm
  Future<void> confirmMakerPayment(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'confirm_payment',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// GET /my-active-offer - This will now query all coordinators
  Future<Map<String, dynamic>?> getMyActiveOffer(String userPubkey, String coordinatorPubkey) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      final request = NostrRequest(method: 'get_my_active_offer', params: {});
      final response = await sendRequest(request, coordinatorPubkey);
      final result = _handleResponse(response, (result) {
        if (result.isEmpty) return null;
        // Add coordinator pubkey to the result
        result['coordinator_pubkey'] = coordinatorPubkey;
        return result;
      });
      if (result != null) {
        return result; // Return the first active offer found
      }
    } catch (e) {
      // Continue to the next coordinator if one fails
      print(
        "Error getting active offer from coordinator ${coordinatorPubkey}: $e",
      );
    }
    return null; // No active offer found on any coordinator
  }

  /// GET /my-finished-offers - This will now query all coordinators
  Future<List<Offer>> getMyFinishedOffers(String userPubkey) async {
    if (!_isInitialized) {
      await init();
    }

    final allOffers = <Offer>[];
    final coordinators = _discoveredCoordinators.values.toList();
    if (coordinators.isEmpty) {
      print("No coordinators discovered, cannot get finished offers.");
      return [];
    }

    final List<Future<List<Offer>>> offerFutures = [];

    for (final coordinator in coordinators) {
      offerFutures.add(
        _getMyFinishedOffersFromCoordinator(userPubkey, coordinator.pubkey),
      );
    }

    final List<List<Offer>> results = await Future.wait(offerFutures);
    for (final offerList in results) {
      allOffers.addAll(offerList);
    }

    allOffers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allOffers;
  }

  Future<List<Offer>> _getMyFinishedOffersFromCoordinator(
    String userPubkey,
    String coordinatorPubkey,
  ) async {
    try {
      final request = NostrRequest(
        method: 'get_my_finished_offers',
        params: {},
      );
      final response = await sendRequest(request, coordinatorPubkey);
      return _handleResponse(response, (result) {
        final List<dynamic> jsonList = result['offers'] ?? [];
        return jsonList.map((json) {
          final offer = Offer.fromJson(json);
          return offer.copyWith(coordinatorPubkey: coordinatorPubkey);
        }).toList();
      });
    } catch (e) {
      print(
        "Error getting finished offers from coordinator $coordinatorPubkey: $e",
      );
      return [];
    }
  }

  /// DELETE /offers/{offerId}/cancel
  Future<void> cancelOffer(String offerId, String coordinatorPubkey) async {
    final request = NostrRequest(
      method: 'cancel_offer',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// DELETE /offers/{offerId}/reservation (taker cancels reservation)
  Future<void> cancelReservation(
    String offerId,
    String takerPubkey,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'cancel_reservation',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// POST /offers/{offerId}/update-invoice
  Future<void> updateTakerInvoice({
    required String offerId,
    required String newBolt11,
    required String userPubkey,
    required String coordinatorPubkey,
  }) async {
    final request = NostrRequest(
      method: 'update_taker_invoice',
      params: {'offer_id': offerId, 'bolt11': newBolt11},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// POST /offers/{offerId}/retry-taker-payment
  Future<void> retryTakerPayment({
    required String offerId,
    required String userPubkey,
    required String coordinatorPubkey,
  }) async {
    final request = NostrRequest(
      method: 'retry_taker_payment',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// POST /offers/{offerId}/blik-invalid
  Future<void> markBlikInvalid(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'mark_blik_invalid',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  Future<void> markOfferConflict(
    String offerId,
    String coordinatorPubkey,
  ) async {
    final request = NostrRequest(
      method: 'mark_offer_conflict',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  Future<void> openDispute(String offerId, String coordinatorPubkey) async {
    final request = NostrRequest(
      method: 'open_dispute',
      params: {'offer_id': offerId},
    );

    final response = await sendRequest(request, coordinatorPubkey);
    _handleResponse(response, (result) => null);
  }

  /// Get coordinator info by pubkey (from cache or discovery)
  CoordinatorInfo? getCoordinatorInfoByPubkey(String coordinatorPubkey) {
    // Check cache first
    if (_coordinatorInfoCache.containsKey(coordinatorPubkey)) {
      return _coordinatorInfoCache[coordinatorPubkey];
    }

    // Check discovered coordinators
    final discoveredCoordinator = _discoveredCoordinators[coordinatorPubkey];
    if (discoveredCoordinator != null) {
      final coordinatorInfo = discoveredCoordinator.toCoordinatorInfo();
      // Cache for future use
      _coordinatorInfoCache[coordinatorPubkey] = coordinatorInfo;
      return coordinatorInfo;
    }

    return null;
  }

  /// GET /stats/successful-offers - This will now query all coordinators
  Future<Map<String, dynamic>> getSuccessfulOffersStats() async {
    if (!_isInitialized) {
      await init();
    }

    final coordinators = _discoveredCoordinators.values.toList();
    if (coordinators.isEmpty) {
      print("No coordinators discovered, cannot get stats.");
      return {
        'total_sats': 0,
        'total_offers': 0,
        'offers': <Offer>[],
        'stats': {
          'lifetime': {
            'avg_time_blik_received_to_created_seconds': null,
            'avg_time_taker_paid_to_created_seconds': null,
            'count': 0,
          },
          'last_7_days': {
            'avg_time_blik_received_to_created_seconds': null,
            'avg_time_taker_paid_to_created_seconds': null,
            'count': 0,
          }
        }
      };
    }

    int totalSats = 0;
    int totalOffers = 0;
    final allOffers = <Offer>[];

    // For aggregating stats
    int lifetimeCount = 0;
    int last7DaysCount = 0;
    double lifetimeBlikTimeSum = 0;
    double lifetimePaidTimeSum = 0;
    double last7DaysBlikTimeSum = 0;
    double last7DaysPaidTimeSum = 0;
    int lifetimeBlikTimeValidEntries = 0;
    int lifetimePaidTimeValidEntries = 0;
    int last7DaysBlikTimeValidEntries = 0;
    int last7DaysPaidTimeValidEntries = 0;

    for (final coordinator in coordinators) {
      try {
        final request = NostrRequest(
          method: 'get_successful_offers_stats',
          params: {},
        );
        final response = await sendRequest(request, coordinator.pubkey);
        final stats = _handleResponse(response, (result) {
          if (result.containsKey('offers') && result['offers'] is List) {
            final List<dynamic> offersJson = result['offers'];
            result['offers'] =
                offersJson.map((json) => Offer.fromJson(json)).toList();
          }
          return result;
        });

        // Aggregate basic totals
        totalSats += (stats['total_sats'] as num?)?.toInt() ?? 0;
        totalOffers += (stats['total_offers'] as num?)?.toInt() ?? 0;
        if (stats['offers'] is List<Offer>) {
          allOffers.addAll(stats['offers']);
        }

        // Aggregate nested stats if present
        if (stats.containsKey('stats') && stats['stats'] is Map<String, dynamic>) {
          final nestedStats = stats['stats'] as Map<String, dynamic>;

          // Process lifetime stats
          if (nestedStats.containsKey('lifetime') && nestedStats['lifetime'] is Map<String, dynamic>) {
            final lifetimeStats = nestedStats['lifetime'] as Map<String, dynamic>;
            final count = (lifetimeStats['count'] as num?)?.toInt() ?? 0;
            lifetimeCount += count;

            final blikTime = lifetimeStats['avg_time_blik_received_to_created_seconds'] as num?;
            if (blikTime != null && count > 0) {
              lifetimeBlikTimeSum += blikTime.toDouble() * count;
              lifetimeBlikTimeValidEntries += count;
            }

            final paidTime = lifetimeStats['avg_time_taker_paid_to_created_seconds'] as num?;
            if (paidTime != null && count > 0) {
              lifetimePaidTimeSum += paidTime.toDouble() * count;
              lifetimePaidTimeValidEntries += count;
            }
          }

          // Process last_7_days stats
          if (nestedStats.containsKey('last_7_days') && nestedStats['last_7_days'] is Map<String, dynamic>) {
            final last7DaysStats = nestedStats['last_7_days'] as Map<String, dynamic>;
            final count = (last7DaysStats['count'] as num?)?.toInt() ?? 0;
            last7DaysCount += count;

            final blikTime = last7DaysStats['avg_time_blik_received_to_created_seconds'] as num?;
            if (blikTime != null && count > 0) {
              last7DaysBlikTimeSum += blikTime.toDouble() * count;
              last7DaysBlikTimeValidEntries += count;
            }

            final paidTime = last7DaysStats['avg_time_taker_paid_to_created_seconds'] as num?;
            if (paidTime != null && count > 0) {
              last7DaysPaidTimeSum += paidTime.toDouble() * count;
              last7DaysPaidTimeValidEntries += count;
            }
          }
        }
      } catch (e) {
        print("Error getting stats from coordinator ${coordinator.pubkey}: $e");
      }
    }

    // Sort offers by creation date (most recent first)
    allOffers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return {
      'total_sats': totalSats,
      'total_offers': totalOffers,
      'offers': allOffers,
      'stats': {
        'lifetime': {
          'avg_time_blik_received_to_created_seconds': lifetimeBlikTimeValidEntries > 0
              ? (lifetimeBlikTimeSum / lifetimeBlikTimeValidEntries).round()
              : null,
          'avg_time_taker_paid_to_created_seconds': lifetimePaidTimeValidEntries > 0
              ? (lifetimePaidTimeSum / lifetimePaidTimeValidEntries).round()
              : null,
          'count': lifetimeCount,
        },
        'last_7_days': {
          'avg_time_blik_received_to_created_seconds': last7DaysBlikTimeValidEntries > 0
              ? (last7DaysBlikTimeSum / last7DaysBlikTimeValidEntries).round()
              : null,
          'avg_time_taker_paid_to_created_seconds': last7DaysPaidTimeValidEntries > 0
              ? (last7DaysPaidTimeSum / last7DaysPaidTimeValidEntries).round()
              : null,
          'count': last7DaysCount,
        }
      }
    };
  }

  // --- Coordinator Discovery Methods ---

  /// Start discovering coordinators on the network
  Future<List<DiscoveredCoordinator>> startCoordinatorDiscovery() async {
    if (!_isInitialized) {
      await init();
    }

    final filter = Filter(
      kinds: [KIND_COORDINATOR_INFO],
      // since:
      //     DateTime.now()
      //         .subtract(const Duration(hours: 24))
      //         .millisecondsSinceEpoch ~/
      //     1000,
    );

    final response = _ndk!.requests.query(
      name: "coordinator-discovery",
      filters: [filter],
    );
    await for (final event in response.stream) {
      _handleCoordinatorInfoEvent(event);
    }
    return discoveredCoordinators;
  }

  /// Start listening for offer status updates
  Future<void> startOfferStatusSubscription(
    String coordinatorPubKey,
    String userPubkey,
  ) async {
    if (!_isInitialized) {
      await init();
    }

    // Close existing subscription if any
    if (_offerStatusSubscription != null) {
      await _ndk!.requests.closeSubscription(
        _offerStatusSubscription!.requestId,
      );
    }

    final filter = Filter(
      kinds: [KIND_OFFER_STATUS_UPDATE],
      authors: [coordinatorPubKey],
      pTags: [userPubkey], // Events tagged to the user's pubkey
      since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    final response = _ndk!.requests.subscription(
      name: "offer-status-updates",
      filters: [filter],
    );
    _offerStatusSubscription = response;

    response.stream.listen(_handleOfferStatusEvent);
    print('📊 Started offer status subscription for $userPubkey');
  }

  /// Stop offer status subscription
  Future<void> stopOfferStatusSubscription() async {
    if (_offerStatusSubscription != null) {
      await _ndk!.requests.closeSubscription(
        _offerStatusSubscription!.requestId,
      );
      _offerStatusSubscription = null;
      print('📊 Stopped offer status subscription');
    }
  }

  /// Handle incoming offer status update events
  void _handleOfferStatusEvent(Nip01Event event) async {
    try {
      print(
        '📊 Received offer status update: ${event.id} from ${event.pubKey}',
      );

      // Decrypt the content using NIP-44
      final decryptedContent = await Nip44.decryptMessage(
        event.content,
        _keyService.privateKeyHex!,
        event.pubKey,
      );

      print('🔓 Decrypted status update: $decryptedContent');

      final content = jsonDecode(decryptedContent) as Map<String, dynamic>;
      final statusUpdate = OfferStatusUpdate.fromJson(content, event.pubKey);

      // Emit the status update to listeners
      _offerStatusController.add(statusUpdate);

      print(
        '📊 Processed status update: ${statusUpdate.offerId} -> ${statusUpdate.status}',
      );
    } catch (e) {
      print('❌ Error handling offer status event: $e');
    }
  }

  /// Get stream of offer status updates
  Stream<OfferStatusUpdate> get offerStatusStream =>
      _offerStatusController.stream;

  /// Handle incoming coordinator info events
  void  _handleCoordinatorInfoEvent(Nip01Event event) {
    try {
      final coordinator = DiscoveredCoordinator.fromNostrEvent(event);
      if (kWhitelistCoordinatorPubKeys.contains(coordinator.pubkey)) {
        _discoveredCoordinators[coordinator.pubkey] = coordinator;
        final coordinatorPubkey = coordinator.pubkey;
        // Cache coordinator info immediately when discovered
        final coordinatorInfo = coordinator.toCoordinatorInfo();
        _coordinatorInfoCache[coordinator.pubkey] = coordinatorInfo;
        print(
          '🎯 Discovered coordinator: ${coordinator.name} (${coordinator.pubkey})',
        );
        // Check health via get_info after discovery (don't await)
        // checkCoordinatorHealth(coordinatorPubkey);
      }
    } catch (e) {
      print('❌ Error parsing coordinator info event: $e');
    }
  }

  // Add health check
  Future<void> checkCoordinatorHealth(String coordinatorPubkey) async {
    try {
      final request = NostrRequest(method: 'get_info', params: {});
      // Use a shorter timeout for health checks
      await sendRequest(
        request,
        coordinatorPubkey,
      );
      // If no exception, coordinator is responsive
      _markCoordinatorResponsive(coordinatorPubkey, true);
    } catch (e) {
      print(
        '🚨 Coordinator $coordinatorPubkey did not respond to get_info: $e',
      );
      _markCoordinatorResponsive(coordinatorPubkey, false);
    }
  }

  void _markCoordinatorResponsive(String pubkey, bool responsive) {
    if (_discoveredCoordinators.containsKey(pubkey)) {
      _discoveredCoordinators[pubkey]!.responsive = responsive;
      // final c = _discoveredCoordinators[pubkey]!;
      // _discoveredCoordinators[pubkey] = DiscoveredCoordinator(
      //   pubkey: c.pubkey,
      //   name: c.name,
      //   icon: c.icon,
      //   minAmountSats: c.minAmountSats,
      //   maxAmountSats: c.maxAmountSats,
      //   makerFee: c.makerFee,
      //   takerFee: c.takerFee,
      //   reservationSeconds: c.reservationSeconds,
      //   currencies: c.currencies,
      //   version: c.version,
      //   lastSeen: c.lastSeen,
      //   responsive: responsive,
      // );
      // Update listeners
      // _coordinatorsController.add(_discoveredCoordinators.values.toList());
    }
  }

  /// Get current list of discovered coordinators
  List<DiscoveredCoordinator> get discoveredCoordinators {
    final coordinators = _discoveredCoordinators.values.toList();

    // Sort by responsive status (true first), then by name
    coordinators.sort((a, b) {
      // Handle null responsive values - treat null as false
      final aResponsive = a.responsive ?? false;
      final bResponsive = b.responsive ?? false;

      // First sort by responsive status (true first)
      if (aResponsive != bResponsive) {
        return aResponsive ? -1 : 1; // responsive coordinators come first
      }

      // If responsive status is the same, sort by name alphabetically
      return a.name.compareTo(b.name);
    });

    return coordinators;
  }

  /// Update relay configuration
  Future<void> updateRelayConfig(List<String> relayUrls) async {
    final prefs = await SharedPreferences.getInstance();
    _relayUrls = relayUrls;
    await prefs.setStringList(_relayUrlsKey, relayUrls);

    // Reinitialize NDK with new relays if already initialized
    if (_isInitialized) {
      await dispose();
      await init();
      await startCoordinatorDiscovery();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_responseSubscription != null) {
      await _ndk!.requests.closeSubscription(_responseSubscription!.requestId);
    }
    if (_offerStatusSubscription != null) {
      await _ndk!.requests.closeSubscription(
        _offerStatusSubscription!.requestId,
      );
    }
    if (_offerSubscription != null) {
      await _ndk!.requests.closeSubscription(_offerSubscription!.requestId);
    }
    _pendingRequests.clear();
    await _offerStatusController.close();
    await _offerStreamController.close();
    if (_ndk != null) {
      await _ndk!.destroy();
      _ndk = null;
    }
    _isInitialized = false;
  }

  /// Get current relay URLs
  List<String> get relayUrls => List.from(_relayUrls);
}

/// Data class for offer status updates received via Nostr
class OfferStatusUpdate {
  final String offerId;
  final String paymentHash;
  final String status;
  final String coordinatorPubkey;
  DateTime? reservedAt;
  final DateTime timestamp;

  OfferStatusUpdate({
    required this.offerId,
    required this.paymentHash,
    required this.status,
    this.reservedAt,
    required this.coordinatorPubkey,
    required this.timestamp,
  });

  factory OfferStatusUpdate.fromJson(
    Map<String, dynamic> json,
    String coordinatorPubkey,
  ) {
    var a = json['reserved_at'];
    return OfferStatusUpdate(
      offerId: json['offer_id'] as String,
      paymentHash: json['payment_hash'] as String,
      status: json['status'] as String,
      reservedAt:
          a != null
              ? DateTime.fromMillisecondsSinceEpoch((a as int) * 1000)
              : null,
      coordinatorPubkey: coordinatorPubkey,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offer_id': offerId,
      'payment_hash': paymentHash,
      'status': status,
      'coordinator_pubkey': coordinatorPubkey,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

/// Exception for Nostr-related errors
class NostrException implements Exception {
  final String message;
  final String? code;

  NostrException(this.message, {this.code});

  @override
  String toString() =>
      'NostrException: $message${code != null ? ' ($code)' : ''}';
}
