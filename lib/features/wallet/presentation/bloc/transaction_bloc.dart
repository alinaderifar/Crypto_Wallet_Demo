import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required ChainRepository chainRepository,
    required WalletRepository walletRepository,
  }) : _chainRepository = chainRepository,
       _walletRepository = walletRepository,
       super(const TransactionState()) {
    on<TransactionSendRequested>(_onSendRequested);
    on<TransactionHistoryRequested>(_onHistoryRequested);
  }

  final ChainRepository _chainRepository;
  final WalletRepository _walletRepository;

  Future<void> _onSendRequested(
    TransactionSendRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionFlowStatus.loading));
    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      emit(
        state.copyWith(
          status: TransactionFlowStatus.success,
          lastTxHash:
              '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionFlowStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onHistoryRequested(
    TransactionHistoryRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionFlowStatus.loading));
    try {
      final account = await _walletRepository.getCurrentAccount();
      if (account == null) {
        emit(
          state.copyWith(
            status: TransactionFlowStatus.success,
            transactions: const [],
          ),
        );
        return;
      }
      final chain = _chainRepository.selectedChain;
      final address = account.addressForChain(chain.chainId);
      final txs = await _chainRepository.getTransactions(address: address);
      emit(
        state.copyWith(
          status: TransactionFlowStatus.success,
          transactions: txs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionFlowStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
