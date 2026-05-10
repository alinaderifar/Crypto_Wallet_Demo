import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCreateWallet extends AuthEvent {
  final String pin;
  const AuthCreateWallet({required this.pin});
  @override
  List<Object> get props => [pin];
}

class AuthImportWallet extends AuthEvent {
  final String mnemonic;
  final String pin;
  const AuthImportWallet({required this.mnemonic, required this.pin});
  @override
  List<Object> get props => [mnemonic, pin];
}

class AuthVerifyPin extends AuthEvent {
  final String pin;
  const AuthVerifyPin({required this.pin});
  @override
  List<Object> get props => [pin];
}
