import 'package:flutter/foundation.dart';

@immutable
class CoordinatorInfo {
  final String name;
  final int reservationSeconds;
  final double makerFee;
  final double takerFee;
  final int minAmountSats;
  final int maxAmountSats;
  final List<String> currencies;
  final String? nostrNpub; // Made nullable

  const CoordinatorInfo({
    required this.name,
    required this.reservationSeconds,
    required this.makerFee,
    required this.takerFee,
    required this.minAmountSats,
    required this.maxAmountSats,
    required this.currencies,
    required this.nostrNpub,
  });

  factory CoordinatorInfo.fromJson(Map<String, dynamic> json) {
    return CoordinatorInfo(
      name: json['name'] as String,
      reservationSeconds: json['reservation_seconds'] as int,
      makerFee: (json['maker_fee'] as num).toDouble(),
      takerFee: (json['taker_fee'] as num).toDouble(),
      minAmountSats: json['min_amount_sats'] as int,
      maxAmountSats: json['max_amount_sats'] as int,
      currencies:
          (json['currencies'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      nostrNpub: json['nostr_npub'] as String?, // Ensure this is String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reservation_seconds': reservationSeconds,
      'maker_fee': makerFee,
      'taker_fee': takerFee,
      'min_amount_sats': minAmountSats,
      'max_amount_sats': maxAmountSats,
      'currencies': currencies,
      'nostr_npub': nostrNpub,
    };
  }
}
