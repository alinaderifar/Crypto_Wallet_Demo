import 'package:flutter_bloc/flutter_bloc.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(const TransactionState()) {
    on<TransactionSendRequested>(_onSendRequested);
    on<TransactionHistoryRequested>(_onHistoryRequested);
  }

  Future<void> _onSendRequested(
    TransactionSendRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionFlowStatus.loading));
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
        status: TransactionFlowStatus.success,
        lastTxHash:
            '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionFlowStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onHistoryRequested(
    TransactionHistoryRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionFlowStatus.loading));
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(state.copyWith(
        status: TransactionFlowStatus.success,
        transactions: const [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionFlowStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
