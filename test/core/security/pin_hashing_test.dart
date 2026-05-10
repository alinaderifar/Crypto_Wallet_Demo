import 'package:crypto_wallet_demo/core/security/pin_hashing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('newPinHashRecord verifies with same PIN', () {
    final stored = newPinHashRecord('4242');
    expect(verifyPinHashRecord('4242', stored), isTrue);
    expect(verifyPinHashRecord('4243', stored), isFalse);
  });
}
