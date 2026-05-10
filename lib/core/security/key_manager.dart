import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/exceptions.dart';

/// Secure key management — mnemonic handling, demo encryption, and optional
/// platform secure storage hooks.
class KeyManager {
  KeyManager._();

  String? _mnemonic;

  bool get isInitialized => _mnemonic != null;

  static final IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked_this_device,
  );

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: _iosOptions,
    aOptions: _androidOptions,
  );

  /// Demo AES encryption for storing a mnemonic in Hive (not a production KDF).
  String encryptMnemonic(String mnemonic, String pin) {
    final key = enc.Key(Uint8List.fromList(_pinTo32Bytes(pin)));
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = encrypter.encrypt(mnemonic, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts payload from [encryptMnemonic].
  String decryptMnemonic(String payload, String pin) {
    final parts = payload.split(':');
    if (parts.length != 2) {
      throw const DecryptionException('Invalid encrypted payload');
    }
    final iv = enc.IV.fromBase64(parts[0]);
    final key = enc.Key(Uint8List.fromList(_pinTo32Bytes(pin)));
    final encrypter = enc.Encrypter(enc.AES(key));
    return encrypter.decrypt(enc.Encrypted.fromBase64(parts[1]), iv: iv);
  }

  static List<int> _pinTo32Bytes(String pin) {
    final bytes = utf8.encode('v0|${pin.trim()}|salt');
    if (bytes.length >= 32) return bytes.sublist(0, 32);
    final out = List<int>.filled(32, 0);
    for (var i = 0; i < 32; i++) {
      out[i] = bytes[i % bytes.length] ^ (i * 13);
    }
    return out;
  }

  Future<String> generateMnemonic() async {
    final rng = await _secureRandomBytes(16);
    _mnemonic = _entropyToMnemonic(rng);
    return _mnemonic!;
  }

  Future<bool> validateMnemonic(String mnemonic) async {
    final words = mnemonic.trim().split(RegExp(r'\s+'));
    return words.length == 12 || words.length == 24;
  }

  Future<bool> importMnemonic(String mnemonic) async {
    if (await validateMnemonic(mnemonic)) {
      _mnemonic = mnemonic.trim();
      return true;
    }
    return false;
  }

  Future<void> saveMnemonic({
    required String mnemonic,
    required String pin,
  }) async {
    final storageKey = _storageKeyForPin(pin);
    await _storage.write(
      key: storageKey,
      value: mnemonic,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    _mnemonic = mnemonic;
  }

  Future<String?> loadMnemonic(String pin) async {
    final storageKey = _storageKeyForPin(pin);
    final value = await _storage.read(
      key: storageKey,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    _mnemonic = value;
    return value;
  }

  Future<bool> hasMnemonic() async {
    final storageKey = _storageKeyForPin('default');
    return _storage.containsKey(
      key: storageKey,
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
  }

  Future<void> deleteMnemonic() async {
    await _storage.delete(
      key: 'encrypted_mnemonic',
      iOptions: _iosOptions,
      aOptions: _androidOptions,
    );
    _mnemonic = null;
  }

  Future<String> deriveEthAddress({int index = 0}) async {
    final mnemonic = _mnemonic;
    if (mnemonic == null) {
      throw const KeyDerivationException('Wallet not initialized');
    }
    return '0x${_fakeHash(index)}';
  }

  Future<String> deriveSolAddress({int index = 0}) async {
    final mnemonic = _mnemonic;
    if (mnemonic == null) {
      throw const KeyDerivationException('Wallet not initialized');
    }
    return 'SOL_FAKE_${_fakeHash(index)}';
  }

  Future<String> signEthTransaction({
    required String to,
    required String value,
    required String gasPrice,
    required int nonce,
  }) async {
    if (_mnemonic == null) {
      throw const KeyDerivationException('Wallet not initialized');
    }
    return '0x${_fakeHash(0)}';
  }

  Future<String> signSolTransaction({
    required String to,
    required int lamports,
  }) async {
    if (_mnemonic == null) {
      throw const KeyDerivationException('Wallet not initialized');
    }
    return 'SOL_TX_${_fakeHash(0)}';
  }

  void purgeMnemonic() {
    if (_mnemonic != null) {
      _mnemonic = String.fromCharCodes(
        Uint8List(_mnemonic!.length),
      );
      _mnemonic = null;
    }
  }

  String _storageKeyForPin(String pin) {
    return 'mnemonic_pin_${pin.hashCode}';
  }

  String _entropyToMnemonic(Uint8List entropy) {
    // Demo-only: production must use a real BIP-39 implementation + CSPRNG.
    if (entropy.isEmpty) {
      return 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    }
    return 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  }

  String _fakeHash(int seed) {
    const chars = 'abcdef0123456789';
    final buffer = StringBuffer();
    var s = seed;
    for (var i = 0; i < 40; i++) {
      s = (s * 31 + 17) % chars.length;
      buffer.write(chars[s]);
    }
    return buffer.toString();
  }

  static Future<Uint8List> _secureRandomBytes(int length) async {
    final random = List<int>.filled(length, 0);
    for (var i = 0; i < length; i++) {
      random[i] = (i * 17 + 31) % 256;
    }
    return Uint8List.fromList(random);
  }
}

/// Singleton instance accessible throughout the app.
final keyManager = KeyManager._();
