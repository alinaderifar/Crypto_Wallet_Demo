import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/types/either.dart';
import '../../../../core/crypto/hd_wallet_derivation.dart';
import '../entities/transaction.dart';
import '../repositories/chain_repository.dart';
import '../repositories/wallet_repository.dart';

class SendNativeEthParams extends Equatable {
  final String to;
  final String amountEth;
  final String pin;

  const SendNativeEthParams({
    required this.to,
    required this.amountEth,
    required this.pin,
  });

  @override
  List<Object?> get props => [to, amountEth, pin];
}

/// Builds, signs, and broadcasts a simple native ETH transfer on the selected EVM chain.
class SendNativeEth {
  SendNativeEth(this._wallet, this._chain);

  final WalletRepository _wallet;
  final ChainRepository _chain;

  Future<Either<Failure, SendResult>> call(SendNativeEthParams params) async {
    final chain = _chain.selectedChain;
    if (!chain.isEVM) {
      return Left(
        NetworkFailure(message: 'Native send is only wired for EVM chains.'),
      );
    }

    final mnemonic = await _wallet.unlockMnemonic(params.pin);
    if (mnemonic == null) {
      return Left(WalletFailure(message: 'Incorrect PIN'));
    }

    http.Client? httpClient;
    Web3Client? client;
    try {
      final pk = await HdWalletDerivation.ethPrivateKeyBytes(mnemonic);
      final cred = EthPrivateKey(pk);
      httpClient = http.Client();
      client = Web3Client(chain.rpcUrl, httpClient);

      final toAddr = EthereumAddress.fromHex(_normalize0x(params.to));
      final wei = _ethStringToWei(params.amountEth);
      final gasPrice = await client.getGasPrice();
      final nonce = await client.getTransactionCount(cred.address);

      final tx = Transaction(
        to: toAddr,
        value: EtherAmount.inWei(wei),
        gasPrice: gasPrice,
        maxGas: 21000,
        nonce: nonce,
      );

      final chainId = int.parse(chain.chainId);
      final txHash = await client.sendTransaction(cred, tx, chainId: chainId);

      return Right(SendResult(txHash: txHash, chainId: chain.chainId));
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    } finally {
      await client?.dispose();
      httpClient?.close();
    }
  }
}

String _normalize0x(String address) {
  final a = address.trim();
  if (a.startsWith('0x') || a.startsWith('0X')) return a;
  return '0x$a';
}

BigInt _ethStringToWei(String input) {
  final s = input.trim();
  if (s.isEmpty) throw const FormatException('empty amount');
  final parts = s.split('.');
  final wholePart = parts[0].isEmpty ? '0' : parts[0];
  final whole = BigInt.tryParse(wholePart);
  if (whole == null) throw FormatException('invalid whole: $wholePart');
  var frac = parts.length > 1 ? parts[1] : '';
  if (frac.length > 18) frac = frac.substring(0, 18);
  frac = frac.padRight(18, '0');
  final fracWei = frac.isEmpty ? BigInt.zero : BigInt.parse(frac);
  return whole * BigInt.from(10).pow(18) + fracWei;
}
