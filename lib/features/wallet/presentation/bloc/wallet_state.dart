import 'package:equatable/equatable.dart';

import '../../domain/entities/wallet_account.dart';

enum WalletStatus { initial, loading, success, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletAccount? currentAccount;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.currentAccount,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    WalletAccount? currentAccount,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      currentAccount: currentAccount ?? this.currentAccount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentAccount, errorMessage];
}
