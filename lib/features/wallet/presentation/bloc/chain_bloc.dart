import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/chain_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

import 'chain_event.dart';
import 'chain_state.dart';

class ChainBloc extends Bloc<ChainEvent, ChainState> {
  final ChainRepository _repository;
  final WalletRepository _walletRepository;

  ChainBloc({
    required ChainRepository repository,
    required WalletRepository walletRepository,
  }) : _repository = repository,
       _walletRepository = walletRepository,
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
      emit(
        state.copyWith(
          selectedChain: _repository.selectedChain,
          status: ChainStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChainStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onChainRefresh(
    ChainRefreshRequested event,
    Emitter<ChainState> emit,
  ) async {
    emit(state.copyWith(status: ChainStatus.loading));
    try {
      final account = await _walletRepository.getCurrentAccount();
      if (account == null) {
        emit(
          state.copyWith(
            status: ChainStatus.error,
            errorMessage: 'No wallet account',
          ),
        );
        return;
      }
      final chain = _repository.selectedChain;
      final address = account.addressForChain(chain.chainId);
      final balance = await _repository.getBalance(address: address);
      emit(
        state.copyWith(
          status: ChainStatus.success,
          selectedChain: chain,
          currentBalance: balance,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChainStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
