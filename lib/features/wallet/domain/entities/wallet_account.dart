import 'package:equatable/equatable.dart';

/// Represents a wallet account derived from a mnemonic.
class WalletAccount extends Equatable {
  /// The index of this account in the HD wallet derivation path.
  final int index;

  /// The human-readable name for this account (e.g., "Account 1").
  final String label;

  /// The derived address for Ethereum (0x...).
  final String ethAddress;

  /// The derived address for Solana (Base58...).
  final String solAddress;

  /// The timestamp when this account was created.
  final DateTime createdAt;

  const WalletAccount({
    required this.index,
    required this.label,
    required this.ethAddress,
    required this.solAddress,
    required this.createdAt,
  });

  /// Returns the address for the given chain ID.
  String addressForChain(String chainId) {
    switch (chainId) {
      case '1':
      case '137':
      case '11155111':
        return ethAddress;
      case 'solana':
        return solAddress;
      default:
        return ethAddress;
    }
  }

  @override
  List<Object?> get props => [index, ethAddress, solAddress];
}
