import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthWalletCreated extends AuthState {
  const AuthWalletCreated();
}

class AuthWalletImported extends AuthState {
  const AuthWalletImported();
}

class AuthPinVerified extends AuthState {
  const AuthPinVerified();
}

class AuthFailureState extends AuthState {
  final Failure failure;
  const AuthFailureState(this.failure);
  @override
  List<Object?> get props => [failure];
}
