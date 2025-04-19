import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/offer.dart'; // Import the client-side Offer model

class ApiService {
  // TODO: Make base URL configurable
  final String _baseUrl =
      'https://api.bitblik.app'; // Updated backend IP address

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

  // POST /initiate-offer
  Future<Map<String, dynamic>> initiateOffer({
    required int amountSats,
    required int feePercentage,
    required String makerId,
  }) async {
    final url = Uri.parse('$_baseUrl/initiate-offer');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'amount_sats': amountSats,
      'fee_percentage': feePercentage,
      'maker_id': makerId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      // Expects {'holdInvoice': 'lnbc...', 'paymentHash': '...'}
      return _handleResponse(response) as Map<String, dynamic>;
    } catch (e) {
      print('Error calling initiateOffer: $e');
      rethrow; // Rethrow to allow UI to handle it
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
}
