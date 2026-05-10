import 'package:dio/dio.dart';

import '../../domain/entities/chain_config.dart';
import '../../domain/entities/transaction.dart';

/// Data source for fetching blockchain data via RPC endpoints.
///
/// Uses Dio for HTTP requests with connection pooling and timeout handling.
class ChainRemoteDataSource {
  // ignore: unused_field
  final Dio _dio;

  ChainRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            ));

  /// Fetches the balance for an address on the given chain.
  Future<String> getBalance({
    required String address,
    required ChainConfig chain,
  }) async {
    // TODO: Implement chain-specific RPC calls
    // For EVM chains: eth_getBalance
    // For Solana: getBalance
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return '0'; // Placeholder
  }

  /// Fetches recent transactions for an address.
  Future<List<TransactionRecord>> getTransactions({
    required String address,
    required ChainConfig chain,
  }) async {
    // TODO: Implement chain-specific transaction fetching
    // For EVM: Use etherscan/polygonscan API or Alchemy/Infura
    // For Solana: Use solscan API
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return []; // Placeholder
  }

  /// Estimates the network fee for a transaction.
  Future<String> estimateFee({
    required String from,
    required String to,
    required String value,
    required ChainConfig chain,
  }) async {
    // TODO: Implement fee estimation
    // For EVM: eth_gasPrice + eth_estimateGas
    // For Solana: getRecentBlockhash + computeBudget
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (chain.isEVM) {
      return '0.001'; // Placeholder: 0.001 ETH
    }
    return '0.0001'; // Placeholder: 0.0001 SOL
  }

  /// Broadcasts a signed transaction to the network.
  Future<String> sendSignedTransaction({
    required String signedTx,
    required ChainConfig chain,
  }) async {
    // TODO: Implement transaction broadcasting
    // For EVM: eth_sendRawTransaction
    // For Solana: sendTransaction
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }
}

/// Global singleton — initialized during app startup.
late ChainRemoteDataSource chainRemoteDataSource;