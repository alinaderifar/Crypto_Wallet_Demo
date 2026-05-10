import 'package:hive/hive.dart';

import '../../../../core/security/key_manager.dart';
import '../../domain/entities/wallet_account.dart';

/// Local data source using Hive for persisting wallet data.
///
/// Sensitive payloads are encrypted with [keyManager] before storage.
class WalletLocalDataSource {
  static const _boxName = 'wallet_box';
  static const _mnemonicKey = 'encrypted_mnemonic';
  static const _pinHashKey = 'pin_hash';
  static const _accountsKey = 'accounts';
  static const _selectedChainKey = 'selected_chain';
  static const _onboardingDoneKey = 'onboarding_done';

  late Box<dynamic> _box;

  /// Opens the Hive box. Must be called before any other operation.
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  /// Encrypts and stores the mnemonic phrase.
  Future<void> saveMnemonic({
    required String mnemonic,
    required String pin,
  }) async {
    final encrypted = keyManager.encryptMnemonic(mnemonic, pin);
    await _box.put(_mnemonicKey, encrypted);
  }

  /// Decrypts and retrieves the stored mnemonic.
  Future<String?> getMnemonic(String pin) async {
    final encrypted = _box.get(_mnemonicKey);
    if (encrypted == null || encrypted is! String) return null;
    try {
      return keyManager.decryptMnemonic(encrypted, pin);
    } catch (_) {
      return null;
    }
  }

  /// Checks if a mnemonic is already stored.
  Future<bool> hasMnemonic() async {
    return _box.containsKey(_mnemonicKey);
  }

  /// Deletes the stored mnemonic (wallet reset / logout).
  Future<void> deleteMnemonic() async {
    await _box.delete(_mnemonicKey);
    await _box.delete(_accountsKey);
    await _box.delete(_pinHashKey);
    await _box.delete(_selectedChainKey);
    await _box.delete(_onboardingDoneKey);
  }

  Future<void> setOnboardingDone(bool done) async {
    await _box.put(_onboardingDoneKey, done);
  }

  bool isOnboardingDone() {
    if (!_box.containsKey(_onboardingDoneKey) && _box.containsKey(_mnemonicKey)) {
      return true;
    }
    return (_box.get(_onboardingDoneKey) as bool?) ?? false;
  }

  /// Stores derived wallet accounts.
  Future<void> saveAccounts(List<WalletAccount> accounts) async {
    final jsonList = accounts
        .map((a) => {
              'index': a.index,
              'label': a.label,
              'ethAddress': a.ethAddress,
              'solAddress': a.solAddress,
              'createdAt': a.createdAt.toIso8601String(),
            })
        .toList();
    await _box.put(_accountsKey, jsonList);
  }

  /// Retrieves stored wallet accounts.
  Future<List<WalletAccount>> getAccounts() async {
    final jsonList = _box.get(_accountsKey) as List<dynamic>?;
    if (jsonList == null) return [];
    return jsonList.map((dynamic json) {
      final m = json as Map<dynamic, dynamic>;
      return WalletAccount(
        index: m['index'] as int,
        label: m['label'] as String,
        ethAddress: m['ethAddress'] as String,
        solAddress: m['solAddress'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
    }).toList();
  }

  /// Stores the selected chain ID.
  Future<void> saveSelectedChain(String chainId) async {
    await _box.put(_selectedChainKey, chainId);
  }

  /// Retrieves the stored selected chain ID.
  String? getSelectedChain() {
    return _box.get(_selectedChainKey) as String?;
  }
}
