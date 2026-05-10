import 'package:equatable/equatable.dart';

import '../../../../core/crypto/hd_wallet_derivation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/types/either.dart';
import '../entities/wallet_account.dart';
import '../repositories/wallet_repository.dart';

/// Parameters for creating a new wallet.
class CreateWalletParams extends Equatable {
  final String pin;
  const CreateWalletParams({required this.pin});

  @override
  List<Object> get props => [pin];
}

/// Use case: Create a new wallet from scratch.
///
/// Generates a new mnemonic, encrypts it with the provided PIN,
/// persists it to secure storage, and returns the derived account.
class CreateWallet {
  final WalletRepository _repository;

  CreateWallet(this._repository);

  Future<Either<Failure, WalletAccount>> call(CreateWalletParams params) async {
    try {
      final mnemonic = HdWalletDerivation.generateMnemonic();
      final account = await _repository.createWallet(
        mnemonic: mnemonic,
        pin: params.pin,
      );
      return Right(account);
    } catch (e) {
      return Left(WalletFailure(message: e.toString()));
    }
  }
}
