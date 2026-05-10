import 'package:crypto_wallet_demo/core/errors/failures.dart';
import 'package:crypto_wallet_demo/core/types/either.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Either', () {
    test('Left.fold invokes left branch', () {
      const either = Left<Failure, int>(WalletFailure(message: 'x'));
      final out = either.fold((l) => l.message, (r) => 'ok');
      expect(out, 'x');
    });

    test('Right.fold invokes right branch', () {
      const either = Right<Failure, int>(42);
      final out = either.fold((l) => -1, (r) => r);
      expect(out, 42);
    });
  });
}
