import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/chain_config.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/chain_repository.dart';
import '../datasources/chain_remote_data_source.dart';

/// Concrete implementation of ChainRepository using remote data sources.
///
/// Handles blockchain interactions via RPC endpoints with automatic
/// chain switching support.
class ChainRepositoryImpl implements ChainRepository {
  final ChainRemoteDataSource _remoteDataSource;
  ChainConfig _selectedChain;

  ChainRepositoryImpl(
    this._remoteDataSource, {
    ChainConfig? initialChain,
  }) : _selectedChain = initialChain ?? ChainConfig.ethereumMainnet;

  @override
  ChainConfig get selectedChain => _selectedChain;

  @override
  Future<void> setChain(String chainId) async {
    final chain = ChainConfig.fromChainId(chainId);
    if (chain == null) throw ChainNotSupportedException(chainId);
    _selectedChain = chain;
  }

  @override
  List<ChainConfig> get supportedChains => ChainConfig.supportedChains;

  @override
  Future<String> getBalance({
    required String address,
    ChainConfig? chain,
  }) async {
    return _remoteDataSource.getBalance(
      address: address,
      chain: chain ?? _selectedChain,
    );
  }

  @override
  Future<TransactionResult> sendTransaction({
    required String from,
    required String to,
    required String value,
    ChainConfig? chain,
  }) async {
    final targetChain = chain ?? _selectedChain;
    // TODO: Build, sign, and broadcast transaction
    final txHash = await _remoteDataSource.sendSignedTransaction(
      signedTx: 'signed_${DateTime.now().millisecondsSinceEpoch}',
      chain: targetChain,
    );
    return TransactionResult(txHash: txHash, chainId: targetChain.chainId);
  }

  @override
  Future<List<TransactionRecord>> getTransactions({
    required String address,
    ChainConfig? chain,
  }) async {
    return _remoteDataSource.getTransactions(
      address: address,
      chain: chain ?? _selectedChain,
    );
  }

  @override
  Future<String> estimateFee({
    required String from,
    required String to,
    required String value,
    ChainConfig? chain,
  }) async {
    return _remoteDataSource.estimateFee(
      from: from,
      to: to,
      value: value,
      chain: chain ?? _selectedChain,
    );
  }
}

/// Global singleton — initialized during app startup.
late ChainRepositoryImpl chainRepository;