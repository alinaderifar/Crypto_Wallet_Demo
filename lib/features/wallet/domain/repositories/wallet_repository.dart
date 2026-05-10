import '../entities/wallet_account.dart';

/// Abstract repository for wallet operations.
abstract class WalletRepository {
  /// Create a new wallet with the given mnemonic and PIN.
  Future<WalletAccount> createWallet({
    required String mnemonic,
    required String pin,
  });

  /// Import an existing wallet from a mnemonic phrase.
  Future<WalletAccount> importWallet({
    required String mnemonic,
    required String pin,
  });

  /// Get the currently active wallet account.
  Future<WalletAccount?> getCurrentAccount();

  /// Get the list of all derived accounts.
  Future<List<WalletAccount>> getAccounts();

  /// Delete the current wallet (logout / reset).
  Future<void> deleteWallet();

  /// Check if a wallet already exists in storage.
  Future<bool> walletExists();

  /// True when encrypted wallet exists and onboarding is finished (PIN / backup flow).
  Future<bool> isSessionReady();

  /// Mark onboarding finished so the app shell can be shown.
  Future<void> markOnboardingComplete();

  /// Verifies the wallet PIN against the stored hash (or legacy mnemonic decrypt).
  Future<bool> verifyPin(String pin);

  /// Decrypts the stored mnemonic when [pin] is correct.
  Future<String?> unlockMnemonic(String pin);
}
