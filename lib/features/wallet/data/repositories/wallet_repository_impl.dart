import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_data_source.dart';
import '../../domain/entities/wallet_account.dart';

/// Concrete implementation of WalletRepository using local data sources.
///
/// Handles wallet creation, import, and persistence using encrypted storage.
class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _localDataSource;

  WalletRepositoryImpl(this._localDataSource);

  @override
  Future<void> deleteWallet() async {
    await _localDataSource.deleteMnemonic();
  }

  @override
  Future<WalletAccount> importWallet({
    required String mnemonic,
    required String pin,
  }) async {
    await _localDataSource.saveMnemonic(mnemonic: mnemonic, pin: pin);
    final account = _deriveAccounts(mnemonic);
    await _localDataSource.saveAccounts([account]);
    await _localDataSource.setOnboardingDone(true);
    return account;
  }

  @override
  Future<WalletAccount?> getCurrentAccount() async {
    final accounts = await getAccounts();
    if (accounts.isEmpty) return null;
    return accounts.first;
  }

  @override
  Future<List<WalletAccount>> getAccounts() async {
    return _localDataSource.getAccounts();
  }

  @override
  Future<WalletAccount> createWallet({
    required String mnemonic,
    required String pin,
  }) async {
    await _localDataSource.saveMnemonic(mnemonic: mnemonic, pin: pin);
    final account = _deriveAccounts(mnemonic);
    await _localDataSource.saveAccounts([account]);
    await _localDataSource.saveSelectedChain('1'); // Default to Ethereum
    await _localDataSource.setOnboardingDone(false);
    return account;
  }

  @override
  Future<bool> walletExists() async {
    return _localDataSource.hasMnemonic();
  }

  @override
  Future<bool> isSessionReady() async {
    if (!await walletExists()) return false;
    return _localDataSource.isOnboardingDone();
  }

  @override
  Future<void> markOnboardingComplete() async {
    await _localDataSource.setOnboardingDone(true);
  }

  /// Derives wallet accounts from a mnemonic phrase.
  ///
  /// In production, this uses proper HD wallet derivation (BIP-44):
  /// - Ethereum: m/44'/60'/0'/0/{index}
  /// - Solana: m/44'/501'/0'/0/{index}
  WalletAccount _deriveAccounts(String mnemonic) {
    // TODO: Implement actual HD wallet derivation using web3dart/solana SDK
    // These are placeholder addresses generated for demo purposes only.
    final timestamp = DateTime.now();
    return WalletAccount(
      index: 0,
      label: 'Account 1',
      ethAddress: '0x${_fakeAddress()}',
      solAddress: _fakeSolAddress(),
      createdAt: timestamp,
    );
  }

  static String _fakeAddress() {
    // Placeholder — never use in production
    return '742d35Cc6634C0532925a3b844Bc9e7595f2bD18';
  }

  static String _fakeSolAddress() {
    // Placeholder — never use in production
    return 'SOL7x2VqE2xGZ9kD4cQh6N3eW8YFjR5mK9nTpL4sX8cV';
  }
}