import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memory_cache/memory_cache.dart';
import '../models/offer.dart';
import '../models/coordinator_info.dart';
import 'nostr_service.dart';
import 'key_service.dart';

class ApiServiceNostr {
  static const _btcPlnCacheKey = 'btcPlnRate';
  static const _coordinatorInfoCacheKey = 'coordinatorInfo';
  CoordinatorInfo? _cachedCoordinatorInfo;
  DateTime? _coordinatorInfoLastFetched;

  final NostrService _nostrService;
  final KeyService _keyService;

  ApiServiceNostr(this._keyService) : _nostrService = NostrService(_keyService);

  /// Initialize the service
  Future<void> init() async {
    await _keyService.init();
    await _nostrService.init();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _nostrService.dispose();
  }

  // Helper method for handling HTTP responses (for external APIs)
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      String errorMessage = 'API Error: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage += ' - ${errorBody['error']}';
        } else {
          errorMessage += ' - ${response.body}';
        }
      } catch (_) {
        errorMessage += ' - ${response.body}';
      }
      print(errorMessage);
      throw Exception(errorMessage);
    }
  }

  // POST /initiate-offer (fiat version) - via Nostr
  Future<Map<String, dynamic>> initiateOfferFiat({
    required double fiatAmount,
    required String makerId,
    String? coordinatorPubkey,
  }) async {
    try {
      if (coordinatorPubkey == null) {
        throw Exception('Coordinator pubkey is required for offer creation');
      }
      return await _nostrService.initiateOfferFiat(
        fiatAmount: fiatAmount,
        makerId: makerId,
        coordinatorPubkey: coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling initiateOfferFiat: $e');
      rethrow;
    }
  }

  // Define a structure for exchange rate sources
  static final List<Map<String, String>> _exchangeRateSources = [
    {
      'name': 'CoinGecko',
      'url':
          'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=pln',
      'parser': '_parseCoinGeckoResponse',
    },
    {
      'name': 'Yadio',
      'url': 'https://api.yadio.io/exrates/pln',
      'parser': '_parseYadioResponse',
    },
    {
      'name': 'Blockchain.info',
      'url': 'https://blockchain.info/ticker',
      'parser': '_parseBlockchainInfoResponse',
    },
  ];

  static List<String> get exchangeRateSourceNames =>
      _exchangeRateSources.map((s) => s['name']!).toList();

  // Parser for CoinGecko response
  double? _parseCoinGeckoResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final rate = data['bitcoin']['pln'];
      if (rate is num) {
        return rate.toDouble();
      }
    } catch (e) {
      print('Error parsing CoinGecko response: $e');
    }
    return null;
  }

  // Parser for Yadio.io response
  double? _parseYadioResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final rate = data['BTC'];
      if (rate is num) {
        return rate.toDouble();
      }
    } catch (e) {
      print('Error parsing Yadio response: $e');
    }
    return null;
  }

  // Parser for Blockchain.info response
  double? _parseBlockchainInfoResponse(String responseBody) {
    try {
      final data = jsonDecode(responseBody);
      final plnData = data['PLN'];
      if (plnData != null && plnData['last'] is num) {
        return (plnData['last'] as num).toDouble();
      }
    } catch (e) {
      print('Error parsing Blockchain.info response: $e');
    }
    return null;
  }

  // GET BTC/PLN rate from multiple sources with caching (still HTTP)
  Future<double> getBtcPlnRate() async {
    // Check cache first
    final cachedRate = MemoryCache.instance.read<double>(_btcPlnCacheKey);
    if (cachedRate != null) {
      return cachedRate;
    }

    List<Future<double?>> fetchFutures = [];

    for (var source in _exchangeRateSources) {
      fetchFutures.add(_fetchRateFromSource(source));
    }

    final List<double?> results = await Future.wait(fetchFutures);
    final List<double> validRates =
        results.where((rate) => rate != null).cast<double>().toList();

    if (validRates.isNotEmpty) {
      final averageRate =
          validRates.reduce((a, b) => a + b) / validRates.length;
      MemoryCache.instance.create(
        _btcPlnCacheKey,
        averageRate,
        expiry: const Duration(minutes: 5),
      );
      return averageRate;
    } else {
      final lastKnown = MemoryCache.instance.read<double>(_btcPlnCacheKey);
      if (lastKnown != null) {
        print(
          'Returning stale BTC/PLN rate due to all sources failing to fetch.',
        );
        return lastKnown;
      }
      throw Exception('Failed to fetch BTC/PLN rate from all sources.');
    }
  }

  Future<double?> _fetchRateFromSource(Map<String, String> source) async {
    final url = Uri.parse(source['url']!);
    final parserName = source['parser']!;
    final sourceName = source['name']!;

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        double? rate;
        if (parserName == '_parseCoinGeckoResponse') {
          rate = _parseCoinGeckoResponse(response.body);
        } else if (parserName == '_parseYadioResponse') {
          rate = _parseYadioResponse(response.body);
        } else if (parserName == '_parseBlockchainInfoResponse') {
          rate = _parseBlockchainInfoResponse(response.body);
        }
        if (rate != null) {
          print('Successfully fetched rate from $sourceName: $rate');
          return rate;
        } else {
          print('Failed to parse response from $sourceName');
          return null;
        }
      } else {
        print(
          'Failed to fetch BTC/PLN rate from $sourceName: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching BTC/PLN rate from $sourceName: $e');
      return null;
    }
  }

  // GET /offers - via Nostr
  Future<List<Offer>> listAvailableOffers() async {
    try {
      return await _nostrService.listAvailableOffers();
    } catch (e) {
      print('Error calling listAvailableOffers: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/reserve - via Nostr
  Future<DateTime?> reserveOffer(
    String offerId,
    String takerId,
    String coordinatorPubkey,
  ) async {
    try {
      return await _nostrService.reserveOffer(
        offerId,
        takerId,
        coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling reserveOffer: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/blik - via Nostr
  Future<void> submitBlikCode({
    required String offerId,
    required String takerId,
    required String blikCode,
    required String takerLightningAddress,
    required String coordinatorPubkey,
  }) async {
    try {
      await _nostrService.submitBlikCode(
        offerId: offerId,
        takerId: takerId,
        blikCode: blikCode,
        takerLightningAddress: takerLightningAddress,
        coordinatorPubkey: coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling submitBlikCode: $e');
      rethrow;
    }
  }

  // GET /offers/{offerId}/blik - via Nostr
  Future<String?> getBlikCodeForMaker(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    try {
      return await _nostrService.getBlikCodeForMaker(
        offerId,
        makerId,
        coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling getBlikCodeForMaker: $e');
      if (e.toString().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  // POST /offers/{offerId}/confirm - via Nostr
  Future<void> confirmMakerPayment(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    try {
      await _nostrService.confirmMakerPayment(
        offerId,
        makerId,
        coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling confirmMakerPayment: $e');
      rethrow;
    }
  }

  // GET /my-active-offer - via Nostr
  Future<Map<String, dynamic>?> getMyActiveOffer(String userPubkey) async {
    try {
      return await _nostrService.getMyActiveOffer(userPubkey);
    } catch (e) {
      print('Error calling getMyActiveOffer: $e');
      return null;
    }
  }

  // GET /my-finished-offers - via Nostr
  Future<List<Offer>> getMyFinishedOffers(String userPubkey) async {
    try {
      return await _nostrService.getMyFinishedOffers(userPubkey);
    } catch (e) {
      print('Error calling getMyFinishedOffers: $e');
      return [];
    }
  }

  // DELETE /offers/{offerId}/cancel - via Nostr
  Future<void> cancelOffer(
    String offerId,
    String makerId,
    String coordinatorPubkey,
  ) async {
    try {
      await _nostrService.cancelOffer(offerId, makerId, coordinatorPubkey);
    } catch (e) {
      print('Error calling cancelOffer: $e');
      rethrow;
    }
  }

  // DELETE /offers/{offerId}/reservation (taker cancels reservation) - via Nostr
  Future<void> cancelReservation(
    String offerId,
    String takerPubkey,
    String coordinatorPubKey,
  ) async {
    try {
      await _nostrService.cancelReservation(
        offerId,
        takerPubkey,
        coordinatorPubKey,
      );
    } catch (e) {
      print('Error calling cancelReservation: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/update-invoice - via Nostr
  Future<void> updateTakerInvoice({
    required String offerId,
    required String newBolt11,
    required String userPubkey,
    required String coordinatorPubkey,
  }) async {
    try {
      await _nostrService.updateTakerInvoice(
        offerId: offerId,
        newBolt11: newBolt11,
        userPubkey: userPubkey,
        coordinatorPubkey: coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling updateTakerInvoice: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/retry-taker-payment - via Nostr
  Future<void> retryTakerPayment({
    required String offerId,
    required String userPubkey,
    required String coordinatorPubkey,
  }) async {
    try {
      await _nostrService.retryTakerPayment(
        offerId: offerId,
        userPubkey: userPubkey,
        coordinatorPubkey: coordinatorPubkey,
      );
    } catch (e) {
      print('Error calling retryTakerPayment: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/blik-invalid - via Nostr
  Future<void> markBlikInvalid(
    String offerId,
    String makerId,
    String coordinatorPubKey,
  ) async {
    try {
      await _nostrService.markBlikInvalid(offerId, makerId, coordinatorPubKey);
    } catch (e) {
      print('Error calling markBlikInvalid: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/conflict - via Nostr
  Future<void> markOfferConflict(
    String offerId,
    String takerId,
    String coordinatorPubKey,
  ) async {
    try {
      await _nostrService.markOfferConflict(
        offerId,
        takerId,
        coordinatorPubKey,
      );
    } catch (e) {
      print('Error calling markOfferConflict: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/dispute - This might not be needed in Nostr version
  // or could be implemented as a separate dispute resolution mechanism
  Future<void> openDispute(String offerId, String makerLnAddress) async {
    // TODO: Implement dispute mechanism for Nostr version
    // This could involve creating a special event or using a different approach
    throw UnimplementedError(
      'Dispute mechanism not yet implemented for Nostr version',
    );
  }

  /// Get coordinator info by pubkey
  CoordinatorInfo? getCoordinatorInfoByPubkey(String coordinatorPubkey) {
    return _nostrService.getCoordinatorInfoByPubkey(coordinatorPubkey);
  }

  /// Cache coordinator info
  void cacheCoordinatorInfo(String coordinatorPubkey, CoordinatorInfo info) {
    _nostrService.cacheCoordinatorInfo(coordinatorPubkey, info);
  }

  // GET /stats/successful-offers - via Nostr
  Future<Map<String, dynamic>> getSuccessfulOffersStats() async {
    try {
      return await _nostrService.getSuccessfulOffersStats();
    } catch (e) {
      print('Error calling getSuccessfulOffersStats: $e');
      rethrow;
    }
  }

  /// Update Nostr relay configuration
  Future<void> updateRelayConfig(List<String> relayUrls) async {
    await _nostrService.updateRelayConfig(relayUrls);
  }

  /// Start coordinator discovery
  Future<void> startCoordinatorDiscovery() async {
    await _nostrService.startCoordinatorDiscovery();
  }

  /// Start listening for offer status updates
  Future<void> startOfferStatusSubscription(String coordinatorPubKey, String userPubkey) async {
    await _nostrService.startOfferStatusSubscription(coordinatorPubKey, userPubkey);
  }

  /// Stop offer status subscription
  Future<void> stopOfferStatusSubscription() async {
    await _nostrService.stopOfferStatusSubscription();
  }

  /// Get stream of offer status updates
  Stream<OfferStatusUpdate> get offerStatusStream =>
      _nostrService.offerStatusStream;

  /// Get discovered coordinators stream
  Stream<List<DiscoveredCoordinator>> get coordinatorsStream =>
      _nostrService.coordinatorsStream;

  /// Get discovered coordinators list
  List<DiscoveredCoordinator> get discoveredCoordinators =>
      _nostrService.discoveredCoordinators;

  /// Get current relay URLs
  List<String> get relayUrls => _nostrService.relayUrls;
}
