import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chain_repository.dart';

import 'chain_event.dart';
import 'chain_state.dart';

class ChainBloc extends Bloc<ChainEvent, ChainState> {
  final ChainRepository _repository;

  ChainBloc({required ChainRepository repository})
      : _repository = repository,
        super(ChainState(selectedChain: repository.selectedChain)) {
    on<ChainChanged>(_onChainChanged);
    on<ChainRefreshRequested>(_onChainRefresh);
  }

  Future<void> _onChainChanged(
    ChainChanged event,
    Emitter<ChainState> emit,
  ) async {
    try {
      await _repository.setChain(event.chainId);
      emit(state.copyWith(
        selectedChain: _repository.selectedChain,
        status: ChainStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChainStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChainRefresh(
    ChainRefreshRequested event,
    Emitter<ChainState> emit,
  ) async {
    emit(state.copyWith(status: ChainStatus.loading));
    try {
      // TODO: Get wallet address from WalletBloc state
      final balance = await _repository.getBalance(
        address: 'current_wallet_address',
      );
      emit(state.copyWith(
        status: ChainStatus.success,
        currentBalance: balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChainStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}