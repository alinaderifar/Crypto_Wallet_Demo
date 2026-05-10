import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Demo-grade PIN verification: random salt + SHA-256 (not a password KDF).
String newPinHashRecord(String pin) {
  final salt = List<int>.generate(
    16,
    (_) => Random.secure().nextInt(256),
    growable: false,
  );
  final hash = sha256.convert([...salt, ...utf8.encode(pin)]).bytes;
  return '${base64Encode(salt)}:${base64Encode(hash)}';
}

bool verifyPinHashRecord(String pin, String stored) {
  final parts = stored.split(':');
  if (parts.length != 2) return false;
  late final List<int> salt;
  late final List<int> expected;
  try {
    salt = base64Decode(parts[0]);
    expected = base64Decode(parts[1]);
  } catch (_) {
    return false;
  }
  final hash = sha256.convert([...salt, ...utf8.encode(pin)]).bytes;
  if (hash.length != expected.length) return false;
  for (var i = 0; i < hash.length; i++) {
    if (hash[i] != expected[i]) return false;
  }
  return true;
}
