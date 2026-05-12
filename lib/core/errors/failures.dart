import 'package:equatable/equatable.dart';

/// Base failure class for the wallet application.
/// All domain and data layer errors should extend this.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Wallet creation / import failures
class WalletFailure extends Failure {
  const WalletFailure({required super.message, super.code});
}

/// Blockchain interaction failures (RPC, transaction, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.fromException(Exception e) {
    return NetworkFailure(
      message: 'Network error occurred. Please check your connection.',
      code: e.toString(),
    );
  }
}

/// Transaction-specific failures
class TransactionFailure extends Failure {
  final String? transactionHash;

  const TransactionFailure({
    required super.message,
    super.code,
    this.transactionHash,
  });
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? message})
    : super(message: message ?? 'An unexpected error occurred.');
}
