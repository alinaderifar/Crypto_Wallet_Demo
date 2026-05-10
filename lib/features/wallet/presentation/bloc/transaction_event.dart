import 'package:equatable/equatable.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionSendRequested extends TransactionEvent {
  final String to;
  final String value;
  final String chainId;

  const TransactionSendRequested({
    required this.to,
    required this.value,
    required this.chainId,
  });

  @override
  List<Object?> get props => [to, value, chainId];
}

class TransactionHistoryRequested extends TransactionEvent {
  const TransactionHistoryRequested();
}
