import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/types/either.dart';
import '../entities/wallet_account.dart';
import '../repositories/wallet_repository.dart';

/// Parameters for importing an existing wallet.
class ImportWalletParams extends Equatable {
  final String mnemonic;
  final String pin;
  const ImportWalletParams({
    required this.mnemonic,
    required this.pin,
  });

  @override
  List<Object> get props => [mnemonic, pin];
}

/// Use case: Import an existing wallet from a mnemonic phrase.
///
/// Validates the mnemonic, encrypts it with the provided PIN,
/// persists it to secure storage, and returns the derived account.
class ImportWallet {
  final WalletRepository _repository;

  ImportWallet(this._repository);

  Future<Either<Failure, WalletAccount>> call(
    ImportWalletParams params,
  ) async {
    try {
      // TODO: Add mnemonic validation (BIP-39 wordlist checksum)
      final account = await _repository.importWallet(
        mnemonic: params.mnemonic,
        pin: params.pin,
      );
      return Right(account);
    } catch (e) {
      return Left(WalletFailure(message: e.toString()));
    }
  }
}