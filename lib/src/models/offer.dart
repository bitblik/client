enum OfferStatus {
  created, // Initial state, invoice generated but not paid
  funded, // Hold invoice paid by maker, offer listed

  expired, // Offer timed out (e.g., reservation, BLIK confirmation)
  cancelled, // Offer explicitly cancelled by Maker while in 'funded' state

  reserved, // Taker has expressed interest, 15s timer started
  blikReceived, // Taker submitted BLIK, 120s timer started
  blikSentToMaker, // Maker requested BLIK code

  invalidBlik, // Maker marked the BLIK code as invalid

  makerConfirmed, // Maker confirmed BLIK payment success
  settled, // Hold invoice settled by coordinator

  payingTaker, // Taker is being paid
  takerPaymentFailed, // Settled, but LNURL payment to taker failed
  takerPaid, // Taker successfully paid via LNURL-pay
}

// Represents an offer listed by the coordinator.
class Offer {
  final String id;
  final int amountSats;
  final int feeSats;
  final double fiatAmount;
  final String fiatCurrency;
  final String status; // e.g., "funded", "reserved", etc. Use OfferStatus.name
  final DateTime createdAt;
  final String makerPubkey;
  final String? takerPubkey;
  final DateTime? reservedAt;
  final DateTime? blikReceivedAt;
  final String? blikCode;
  final String? holdInvoicePaymentHash;
  // Added fields based on DB schema that might be useful
  final String? takerLightningAddress;
  final String? takerInvoice;
  final String?
  holdInvoicePreimage; // Might be sensitive, consider if needed on client
  final DateTime? updatedAt;
  final DateTime? makerConfirmedAt;
  final DateTime? settledAt;
  final DateTime? takerPaidAt;

  Offer({
    required this.id,
    required this.amountSats,
    required this.feeSats,
    required this.status,
    required this.fiatAmount,
    required this.fiatCurrency,
    required this.createdAt,
    required this.makerPubkey,
    this.takerPubkey,
    this.reservedAt,
    this.blikReceivedAt,
    this.blikCode,
    this.holdInvoicePaymentHash,
    this.takerLightningAddress,
    this.takerInvoice,
    this.holdInvoicePreimage,
    this.updatedAt,
    this.makerConfirmedAt,
    this.settledAt,
    this.takerPaidAt,
  });

  // Factory constructor to create an Offer from JSON data (Map).
  factory Offer.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.parse(dateString) : null;
    }

    return Offer(
      id: json['id'] as String,
      amountSats: json['amount_sats'] as int,
      feeSats: json['fee_sats'] as int,
      fiatAmount: json['fiat_amount']?? 0,
      fiatCurrency: json['fiat_currency']?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      makerPubkey: json['maker_pubkey'] as String? ?? '',
      takerPubkey: json['taker_pubkey'] as String?,
      reservedAt: parseOptionalDateTime(json['reserved_at'] as String?),
      blikReceivedAt: parseOptionalDateTime(
        json['blik_received_at'] as String?,
      ),
      blikCode: json['blik_code'] as String?,
      holdInvoicePaymentHash: json['hold_invoice_payment_hash'] as String?,
      // Parse additional fields if present in JSON
      takerLightningAddress: json['taker_lightning_address'] as String?,
      takerInvoice: json['taker_invoice'] as String?,
      holdInvoicePreimage:
          json['hold_invoice_preimage'] as String?, // Be cautious exposing this
      updatedAt: parseOptionalDateTime(json['updated_at'] as String?),
      makerConfirmedAt: parseOptionalDateTime(
        json['maker_confirmed_at'] as String?,
      ),
      settledAt: parseOptionalDateTime(json['settled_at'] as String?),
      takerPaidAt: parseOptionalDateTime(json['taker_paid_at'] as String?),
    );
  }

  // Method to convert Offer instance back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount_sats': amountSats,
      'fee_sats': feeSats,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'maker_pubkey': makerPubkey,
      'taker_pubkey': takerPubkey,
      'reserved_at': reservedAt?.toIso8601String(),
      'blik_received_at': blikReceivedAt?.toIso8601String(),
      'blik_code': blikCode,
      'hold_invoice_payment_hash': holdInvoicePaymentHash,
      'taker_lightning_address': takerLightningAddress,
      'taker_invoice': takerInvoice,
      'hold_invoice_preimage': holdInvoicePreimage,
      'updated_at': updatedAt?.toIso8601String(),
      'maker_confirmed_at': makerConfirmedAt?.toIso8601String(),
      'settled_at': settledAt?.toIso8601String(),
      'taker_paid_at': takerPaidAt?.toIso8601String(),
    };
  }

  // copyWith method for updating state immutably
  Offer copyWith({
    String? id,
    int? amountSats,
    int? feeSats,
    String? status,
    DateTime? createdAt,
    String? makerPubkey,
    String? takerPubkey,
    DateTime? reservedAt,
    DateTime? blikReceivedAt,
    String? blikCode,
    String? holdInvoicePaymentHash,
    String? takerLightningAddress,
    String? takerInvoice,
    String? holdInvoicePreimage,
    DateTime? updatedAt,
    DateTime? makerConfirmedAt,
    DateTime? settledAt,
    DateTime? takerPaidAt,
  }) {
    return Offer(
      id: id ?? this.id,
      amountSats: amountSats ?? this.amountSats,
      feeSats: feeSats ?? this.feeSats,
      status: status ?? this.status,
      fiatAmount: fiatAmount,
      fiatCurrency: fiatCurrency,
      createdAt: createdAt ?? this.createdAt,
      makerPubkey: makerPubkey ?? this.makerPubkey,
      takerPubkey: takerPubkey ?? this.takerPubkey,
      reservedAt: reservedAt ?? this.reservedAt,
      blikReceivedAt: blikReceivedAt ?? this.blikReceivedAt,
      blikCode: blikCode ?? this.blikCode,
      holdInvoicePaymentHash:
          holdInvoicePaymentHash ?? this.holdInvoicePaymentHash,
      takerLightningAddress:
          takerLightningAddress ?? this.takerLightningAddress,
      takerInvoice: takerInvoice ?? this.takerInvoice,
      holdInvoicePreimage: holdInvoicePreimage ?? this.holdInvoicePreimage,
      updatedAt: updatedAt ?? this.updatedAt,
      makerConfirmedAt: makerConfirmedAt ?? this.makerConfirmedAt,
      settledAt: settledAt ?? this.settledAt,
      takerPaidAt: takerPaidAt ?? this.takerPaidAt,
    );
  }

  @override
  String toString() {
    return 'Offer(id: $id, amountSats: $amountSats, feeSats: $feeSats, status: $status, maker: ${makerPubkey.substring(0, 6)}..., taker: ${takerPubkey?.substring(0, 6)}..., createdAt: $createdAt)';
  }
}
