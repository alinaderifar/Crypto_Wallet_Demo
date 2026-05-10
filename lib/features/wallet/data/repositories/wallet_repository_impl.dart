import '../../../../core/crypto/hd_wallet_derivation.dart';
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
    final account = await _deriveAccount(mnemonic);
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
    final account = await _deriveAccount(mnemonic);
    await _localDataSource.saveAccounts([account]);
    await _localDataSource.saveSelectedChain('11155111');
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

  @override
  Future<bool> verifyPin(String pin) => _localDataSource.verifyPin(pin);

  @override
  Future<String?> unlockMnemonic(String pin) =>
      _localDataSource.getMnemonic(pin);

  Future<WalletAccount> _deriveAccount(String mnemonic) async {
    final d = await HdWalletDerivation.deriveAddresses(mnemonic);
    return WalletAccount(
      index: 0,
      label: 'Account 1',
      ethAddress: d.ethAddress,
      solAddress: d.solAddress,
      createdAt: DateTime.now(),
    );
  }
}
