import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/chain_config.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/chain_repository.dart';
import '../datasources/chain_remote_data_source.dart';
import '../datasources/wallet_local_data_source.dart';

/// Concrete implementation of ChainRepository using remote data sources.
///
/// Handles blockchain interactions via RPC endpoints with automatic
/// chain switching support.
class ChainRepositoryImpl implements ChainRepository {
  ChainRepositoryImpl(this._remoteDataSource, this._walletLocal)
    : _selectedChain = _initialChain(_walletLocal);

  final ChainRemoteDataSource _remoteDataSource;
  final WalletLocalDataSource _walletLocal;
  ChainConfig _selectedChain;

  static ChainConfig _initialChain(WalletLocalDataSource local) {
    final id = local.getSelectedChain();
    return ChainConfig.fromChainId(id ?? '') ?? ChainConfig.sepolia;
  }

  @override
  ChainConfig get selectedChain => _selectedChain;

  @override
  Future<void> setChain(String chainId) async {
    final chain = ChainConfig.fromChainId(chainId);
    if (chain == null) throw ChainNotSupportedException(chainId);
    _selectedChain = chain;
    await _walletLocal.saveSelectedChain(chainId);
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
    throw UnsupportedError(
      'Sign locally then use broadcastSignedEvmTx (see SendNativeEth use case).',
    );
  }

  @override
  Future<TransactionResult> broadcastSignedEvmTx({
    required String signedTxHex,
    ChainConfig? chain,
  }) async {
    final targetChain = chain ?? _selectedChain;
    final txHash = await _remoteDataSource.sendSignedTransaction(
      signedTx: signedTxHex,
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
