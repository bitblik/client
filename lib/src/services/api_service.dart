import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:memory_cache/memory_cache.dart';
import '../models/offer.dart'; // Import the client-side Offer model
import '../models/coordinator_info.dart';

class ApiService {
  static const _btcPlnCacheKey = 'btcPlnRate';
  static const _coordinatorInfoCacheKey = 'coordinatorInfo';
  CoordinatorInfo? _cachedCoordinatorInfo;
  DateTime? _coordinatorInfoLastFetched;

  // TODO: Make base URL configurable
  final String _baseUrl =
      kDebugMode ? 'http://0.0.0.0:8080' : 'https://api.bitblik.app';

  // Helper method for handling HTTP responses
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null; // Or return a specific success indicator if needed
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
        // Ignore if body is not valid JSON
        errorMessage += ' - ${response.body}';
      }
      print(errorMessage); // Log the error
      throw Exception(errorMessage);
    }
  }

  // POST /initiate-offer (fiat version)
  Future<Map<String, dynamic>> initiateOfferFiat({
    required double fiatAmount,
    required String makerId,
  }) async {
    final url = Uri.parse('$_baseUrl/initiate-offer');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'fiat_amount': fiatAmount,
      'maker_id': makerId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      print('Error calling initiateOfferFiat: $e');
      rethrow;
    }
  }

  // GET BTC/PLN rate from CoinGecko with caching
  Future<double> getBtcPlnRate() async {
    // Check cache first
    final cachedRate = MemoryCache.instance.read<double>(_btcPlnCacheKey);
    if (cachedRate != null) {
      return cachedRate;
    }

    // If not in cache, fetch from API
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=pln',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['bitcoin']['pln'];
        if (rate is num) {
          final doubleRate = rate.toDouble();
          // Write to cache with 5-minute expiry
          MemoryCache.instance.create(
            _btcPlnCacheKey,
            doubleRate,
            expiry: const Duration(minutes: 5),
          );
          return doubleRate;
        } else {
          throw Exception('Invalid rate format received from CoinGecko');
        }
      } else {
        throw Exception(
          'Failed to fetch BTC/PLN rate: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching BTC/PLN rate from CoinGecko: $e');
      // Attempt to return last known value if fetch fails, otherwise rethrow
      final lastKnown = MemoryCache.instance.read<double>(_btcPlnCacheKey);
      if (lastKnown != null) {
        print('Returning stale BTC/PLN rate due to fetch error.');
        return lastKnown;
      }
      rethrow;
    }
  }

  // GET /offers
  Future<List<Offer>> listAvailableOffers() async {
    final url = Uri.parse('$_baseUrl/offers');
    try {
      final response = await http.get(url);
      final List<dynamic> jsonList = _handleResponse(response);
      return jsonList.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      print('Error calling listAvailableOffers: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/reserve
  // Returns the reservation timestamp on success, null on failure/error
  Future<DateTime?> reserveOffer(String offerId, String takerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/reserve');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'taker_id': takerId});

    try {
      final response = await http.post(url, headers: headers, body: body);
      final jsonResponse = _handleResponse(
        response,
      ); // Throws on error status code
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('reserved_at')) {
        final timestampString = jsonResponse['reserved_at'] as String?;
        if (timestampString != null) {
          return DateTime.tryParse(
            timestampString,
          )?.toLocal(); // Parse and convert to local time
        }
      }
      // If response is not as expected or timestamp is missing/invalid
      print(
        'Warning: reserveOffer response did not contain a valid reserved_at timestamp.',
      );
      return null;
    } catch (e) {
      print('Error calling reserveOffer: $e');
      rethrow;
    }
  }

  // POST /offers/{offerId}/blik
  Future<void> submitBlikCode({
    required String offerId,
    required String takerId,
    required String blikCode,
    required String takerLightningAddress,
  }) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/blik');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'taker_id': takerId,
      'blik_code': blikCode,
      'taker_lightning_address': takerLightningAddress,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      _handleResponse(response); // Throws on error
    } catch (e) {
      print('Error calling submitBlikCode: $e');
      rethrow;
    }
  }

  // GET /offers/{offerId}/blik
  Future<String?> getBlikCodeForMaker(String offerId, String makerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/blik');
    // Pass makerId via header as per backend implementation
    final headers = {'x-maker-id': makerId};

    try {
      final response = await http.get(url, headers: headers);
      final Map<String, dynamic>? result = _handleResponse(response);
      return result?['blik_code'] as String?;
    } catch (e) {
      print('Error calling getBlikCodeForMaker: $e');
      if (e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  // POST /offers/{offerId}/confirm
  Future<void> confirmMakerPayment(String offerId, String makerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/confirm');
    final headers = {'x-maker-id': makerId, 'Content-Type': 'application/json'};
    final body = jsonEncode({});

    try {
      final response = await http.post(url, headers: headers, body: body);
      _handleResponse(response); // Throws on error
    } catch (e) {
      print('Error calling confirmMakerPayment: $e');
      rethrow;
    }
  }

  // GET /offer-status/{paymentHash}
  Future<String?> getOfferStatus(String paymentHash) async {
    final url = Uri.parse('$_baseUrl/offer-status/$paymentHash');
    try {
      final response = await http.get(url);
      final Map<String, dynamic>? result = _handleResponse(response);
      return result?['status'] as String?; // Returns status name string or null
    } catch (e) {
      print('Error calling getOfferStatus: $e');
      return null;
    }
  }

  // GET /my-active-offer
  Future<Map<String, dynamic>?> getMyActiveOffer(String userPubkey) async {
    final url = Uri.parse('$_baseUrl/my-active-offer');
    final headers = {'x-user-pubkey': userPubkey};

    try {
      final response = await http.get(url, headers: headers);
      final Map<String, dynamic>? result = _handleResponse(response);
      if (result != null && result.isNotEmpty) {
        return result;
      } else {
        return null; // No active offer found
      }
    } catch (e) {
      print('Error calling getMyActiveOffer: $e');
      return null;
    }
  }

  // GET /my-finished-offers
  Future<List<Offer>> getMyFinishedOffers(String userPubkey) async {
    final url = Uri.parse('$_baseUrl/my-finished-offers');
    final headers = {'x-user-pubkey': userPubkey};

    try {
      final response = await http.get(url, headers: headers);
      final List<dynamic>? result = _handleResponse(response);
      if (result != null && result.isNotEmpty) {
        return result.map((json) => Offer.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error calling getMyFinishedOffers: $e');
      return [];
    }
  }

  // DELETE /offers/{offerId}/cancel
  Future<void> cancelOffer(String offerId, String makerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/cancel');
    final headers = {'x-maker-id': makerId}; // Send maker ID for auth

    try {
      final response = await http.delete(url, headers: headers);
      _handleResponse(response); // Throws on error (e.g., 404, 403, 409)
    } catch (e) {
      print('Error calling cancelOffer: $e');
      rethrow; // Rethrow to allow UI to handle it
    }
  }

  Future<void> updateTakerInvoice({
    required String offerId,
    required String newBolt11,
    required String userPubkey,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/offers/$offerId/update-invoice'),
      headers: {
        'Content-Type': 'application/json',
        'x-user-pubkey': userPubkey,
      },
      body: jsonEncode({'bolt11': newBolt11}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update invoice');
    }
  }

  // POST /offers/{offerId}/retry-taker-payment
  Future<void> retryTakerPayment({
    required String offerId,
    required String userPubkey,
  }) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/retry-taker-payment');
    final headers = {
      'Content-Type': 'application/json',
      'x-user-pubkey': userPubkey,
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({}),
    );
    if (response.statusCode != 200) {
      String errorMessage =
          'Failed to retry taker payment: ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('error')) {
          errorMessage += ' - ${errorBody['error']}';
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // POST /offers/{offerId}/blik-invalid
  Future<void> markBlikInvalid(String offerId, String makerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/blik-invalid');
    final headers = {
      'Content-Type': 'application/json',
      'x-maker-id': makerId, // Assuming authentication via header
    };
    final body = jsonEncode({}); // Empty body, just need the POST request

    try {
      final response = await http.post(url, headers: headers, body: body);
      _handleResponse(response); // Throws on error (e.g., 404, 403, 409)
    } catch (e) {
      print('Error calling markBlikInvalid: $e');
      rethrow; // Rethrow to allow UI to handle it
    }
  }

  // POST /offers/{offerId}/conflict
  Future<void> markOfferConflict(String offerId, String takerId) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/conflict');
    final headers = {
      'Content-Type': 'application/json',
      'x-user-pubkey': takerId, // Send taker ID for auth
    };
    final body = jsonEncode({}); // Empty body

    try {
      final response = await http.post(url, headers: headers, body: body);
      _handleResponse(response); // Throws on error (e.g., 404, 403, 409)
    } catch (e) {
      print('Error calling markOfferConflict: $e');
      rethrow; // Rethrow to allow UI to handle it
    }
  }

  // POST /offers/{offerId}/dispute - Maker opens dispute
  Future<void> openDispute(String offerId, String makerLnAddress) async {
    final url = Uri.parse('$_baseUrl/offers/$offerId/dispute');
    print(
      'Calling POST $url with makerLnAddress: $makerLnAddress',
    ); // Debug log
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'maker_lightning_address': makerLnAddress});

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Dispute Response Status: ${response.statusCode}'); // Debug log
      print('Dispute Response Data: ${response.body}'); // Debug log
      _handleResponse(response); // Throws on non-2xx status
    } catch (e) {
      print('Error opening dispute: $e'); // Debug log
      rethrow; // Rethrow to allow UI to handle it
    }
  }

  // GET /info
  Future<CoordinatorInfo> getCoordinatorInfo() async {
    final now = DateTime.now();
    if (_cachedCoordinatorInfo != null &&
        _coordinatorInfoLastFetched != null &&
        now.difference(_coordinatorInfoLastFetched!) <
            const Duration(hours: 1)) {
      return _cachedCoordinatorInfo!;
    }

    final url = Uri.parse('$_baseUrl/info');
    try {
      final response = await http.get(url);
      final Map<String, dynamic> json = _handleResponse(response);
      final info = CoordinatorInfo.fromJson(json);
      _cachedCoordinatorInfo = info;
      _coordinatorInfoLastFetched = now;
      MemoryCache.instance.create(
        _coordinatorInfoCacheKey,
        info.toJson(), // Cache the JSON representation
        expiry: const Duration(hours: 1),
      );
      return info;
    } catch (e) {
      print('Error calling getCoordinatorInfo: $e');
      // Attempt to return from memory cache if fetch fails
      final cached = MemoryCache.instance.read<Map<String, dynamic>>(
        _coordinatorInfoCacheKey,
      );
      if (cached != null) {
        print('Returning stale CoordinatorInfo from cache due to fetch error.');
        _cachedCoordinatorInfo = CoordinatorInfo.fromJson(cached);
        // Consider if _coordinatorInfoLastFetched should be updated or cleared here
        return _cachedCoordinatorInfo!;
      }
      rethrow;
    }
  }
}
