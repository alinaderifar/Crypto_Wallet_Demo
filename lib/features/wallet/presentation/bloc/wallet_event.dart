import 'package:equatable/equatable.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class WalletCreateRequested extends WalletEvent {
  final String pin;
  const WalletCreateRequested({required this.pin});
  @override
  List<Object> get props => [pin];
}

class WalletImportRequested extends WalletEvent {
  final String mnemonic;
  final String pin;
  const WalletImportRequested({
    required this.mnemonic,
    required this.pin,
  });
  @override
  List<Object> get props => [mnemonic, pin];
}

class WalletLogoutRequested extends WalletEvent {
  const WalletLogoutRequested();
}
