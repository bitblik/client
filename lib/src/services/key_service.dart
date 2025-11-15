import 'dart:math'; // For Random.secure()
import 'dart:typed_data'; // For Uint8List

import 'package:bip340/bip340.dart' as bip340;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ndk/shared/logger/logger.dart';

// Helper function for hex encoding
String bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
}

// Helper function for hex decoding
Uint8List hexToBytes(String hex) {
  hex = hex.replaceAll(RegExp(r'\s+'), ''); // Remove spaces if any
  if (hex.length % 2 != 0) {
    hex = '0$hex'; // Pad with leading zero if odd length
  }
  final bytes = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    final hexPair = hex.substring(i, i + 2);
    bytes.add(int.parse(hexPair, radix: 16));
  }
  // Ensure the output is Uint8List, often required by crypto libs
  return Uint8List.fromList(bytes);
}

class KeyService {
  final _storage = const FlutterSecureStorage();
  final _privateKeyStorageKey = 'bitblik_private_key_hex';
  final _lightningAddressStorageKey = 'bitblik_lightning_address'; // New key

  String? _publicKeyHex;
  String? _privateKeyHex; // Store keys as hex strings

  // Public getter for the public key (hex format)
  String? get publicKeyHex => _publicKeyHex;

  // Public getter for the private key (hex format) - Use with caution!
  String? get privateKeyHex => _privateKeyHex;

  // Initializes the service: loads existing key or generates a new one.
  Future<void> init() async {
    if (_publicKeyHex != null) return; // Already initialized

    try {
      final storedPrivateKeyHex = await _storage.read(
        key: _privateKeyStorageKey,
      );

      if (storedPrivateKeyHex != null && storedPrivateKeyHex.isNotEmpty) {
        // Basic validation: check length (should be 64 hex chars for 32 bytes)
        if (storedPrivateKeyHex.length == 64 &&
            RegExp(r'^[0-9a-fA-F]+$').hasMatch(storedPrivateKeyHex)) {
          _privateKeyHex = storedPrivateKeyHex;
          // Derive public key from private key hex string
          _publicKeyHex = bip340.getPublicKey(
            _privateKeyHex!,
          ); // Pass hex string
          Logger.log.i('✅ Loaded existing key pair. Public key: $_publicKeyHex');
        } else {
          Logger.log.w(
            '⚠️ Stored private key hex is invalid ($storedPrivateKeyHex). Generating new key pair.',
          );
          await generateNewKeyPair();
        }
      } else {
        // Generate new key pair
        await generateNewKeyPair();
        Logger.log.i(
          '🔑 Generated and stored new key pair. Public key: $_publicKeyHex',
        );
      }
    } catch (e) {
      Logger.log.e('❌ Error initializing KeyService: $e');
      _publicKeyHex = null;
      _privateKeyHex = null;
      // Consider attempting to generate fresh keys on error?
      // await _generateAndStoreKeyPair();
    }
  }

  // Generates a new key pair and stores the private key
  Future<void> generateNewKeyPair() async {
    // Generate 32 random bytes for the private key
    final random = Random.secure();
    final privateKeyBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );

    // Convert bytes to hex for bip340 functions and storage
    _privateKeyHex = bytesToHex(privateKeyBytes);
    // Derive public key from the hex private key
    _publicKeyHex = bip340.getPublicKey(_privateKeyHex!);

    // Store the new private key securely
    await _storage.write(key: _privateKeyStorageKey, value: _privateKeyHex);
  }

  // Saves a provided private key, replacing the existing one.
  Future<void> savePrivateKey(String privateKeyHex) async {
    // Basic validation
    if (privateKeyHex.length != 64 ||
        !RegExp(r'^[0-9a-fA-F]+$').hasMatch(privateKeyHex)) {
      throw ArgumentError(
        'Invalid private key format. It must be a 64-character hex string.',
      );
    }

    // Update the in-memory keys
    _privateKeyHex = privateKeyHex;
    _publicKeyHex = bip340.getPublicKey(_privateKeyHex!);

    // Store the new private key securely, overwriting the old one
    await _storage.write(key: _privateKeyStorageKey, value: _privateKeyHex);
    Logger.log.i('✅ Restored and saved new key pair. Public key: $_publicKeyHex');
  }

  // Optional: Method to delete keys (for testing or user request)
  Future<void> deleteKeys() async {
    await _storage.delete(key: _privateKeyStorageKey);
    _publicKeyHex = null;
    _privateKeyHex = null;
    Logger.log.i('🔑 Deleted stored key pair.');
    // Also delete lightning address
    await _storage.delete(key: _lightningAddressStorageKey);
    Logger.log.i('⚡️ Deleted stored Lightning Address.');
  }

  // --- Lightning Address Methods ---

  // Saves the Lightning Address securely
  Future<void> saveLightningAddress(String address) async {
    try {
      await _storage.write(key: _lightningAddressStorageKey, value: address);
      Logger.log.i('⚡️ Saved Lightning Address.');
    } catch (e) {
      Logger.log.e('❌ Error saving Lightning Address: $e');
      rethrow; // Allow calling code to handle error
    }
  }

  // Retrieves the Lightning Address
  Future<String?> getLightningAddress() async {
    try {
      final address = await _storage.read(key: _lightningAddressStorageKey);
      Logger.log.i('⚡️ Retrieved Lightning Address: $address');
      return address;
    } catch (e) {
      Logger.log.e('❌ Error retrieving Lightning Address: $e');
      return null; // Return null on error
    }
  }
}
