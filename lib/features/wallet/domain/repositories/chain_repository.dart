import '../entities/chain_config.dart';
import '../entities/transaction.dart';

/// Abstract repository for chain/network operations.
abstract class ChainRepository {
  /// Get the currently selected chain.
  ChainConfig get selectedChain;

  /// Set the active chain by ID.
  Future<void> setChain(String chainId);

  /// Get the list of supported chains.
  List<ChainConfig> get supportedChains;

  /// Get the balance for an address on the current chain.
  Future<String> getBalance({
    required String address,
    ChainConfig? chain,
  });

  /// Send a transaction on the current chain.
  Future<TransactionResult> sendTransaction({
    required String from,
    required String to,
    required String value,
    ChainConfig? chain,
  });

  /// Get transaction history for an address.
  Future<List<TransactionRecord>> getTransactions({
    required String address,
    ChainConfig? chain,
  });

  /// Estimate the network fee for a transaction.
  Future<String> estimateFee({
    required String from,
    required String to,
    required String value,
    ChainConfig? chain,
  });
}

/// Result type for transaction submission.
class TransactionResult {
  final String txHash;
  final String chainId;

  const TransactionResult({
    required this.txHash,
    required this.chainId,
  });
}