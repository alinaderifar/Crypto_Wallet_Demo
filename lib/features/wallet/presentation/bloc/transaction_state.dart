import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';

enum TransactionFlowStatus { initial, loading, success, error }

class TransactionState extends Equatable {
  final TransactionFlowStatus status;
  final List<TransactionRecord> transactions;
  final String? lastTxHash;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionFlowStatus.initial,
    this.transactions = const [],
    this.lastTxHash,
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionFlowStatus? status,
    List<TransactionRecord>? transactions,
    String? lastTxHash,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      lastTxHash: lastTxHash ?? this.lastTxHash,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, lastTxHash, errorMessage];
}
