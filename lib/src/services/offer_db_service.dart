import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/offer.dart';

class OfferDbService {
  static final OfferDbService _instance = OfferDbService._internal();
  factory OfferDbService() => _instance;
  OfferDbService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = kIsWeb? "bitblik.db" : await getDatabasesPath();
    final path = join(dbPath, 'offer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE active_offer (
            id TEXT PRIMARY KEY,
            amountSats INTEGER,
            makerFees INTEGER,
            fiatAmount REAL,
            fiatCurrency TEXT,
            status TEXT,
            createdAt TEXT,
            makerPubkey TEXT,
            coordinatorPubkey TEXT,
            takerPubkey TEXT,
            reservedAt TEXT,
            blikReceivedAt TEXT,
            blikCode TEXT,
            holdInvoicePaymentHash TEXT,
            takerLightningAddress TEXT,
            takerInvoice TEXT,
            holdInvoicePreimage TEXT,
            updatedAt TEXT,
            makerConfirmedAt TEXT,
            settledAt TEXT,
            takerPaidAt TEXT,
            takerFees INTEGER
          )
        ''');
      },
    );
  }

  Future<void> upsertActiveOffer(Offer offer) async {
    final db = await database;
    await db.insert(
      'active_offer',
      offer.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Offer?> getActiveOffer() async {
    final db = await database;
    final maps = await db.query('active_offer', limit: 1);
    if (maps.isNotEmpty) {
      return Offer.fromJson(maps.first);
    }
    return null;
  }

  Future<void> deleteActiveOffer() async {
    final db = await database;
    await db.delete('active_offer');
  }
}
