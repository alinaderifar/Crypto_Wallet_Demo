import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_account.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/usecases/create_wallet.dart';
import '../../domain/usecases/import_wallet.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final CreateWallet _createWallet;
  final ImportWallet _importWallet;
  final WalletRepository _walletRepository;

  WalletBloc({
    required CreateWallet createWallet,
    required ImportWallet importWallet,
    required WalletRepository walletRepository,
  })  : _createWallet = createWallet,
        _importWallet = importWallet,
        _walletRepository = walletRepository,
        super(const WalletState()) {
    on<WalletCreateRequested>(_onCreateRequested);
    on<WalletImportRequested>(_onImportRequested);
    on<WalletLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCreateRequested(
    WalletCreateRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));
    final result = await _createWallet(CreateWalletParams(pin: event.pin));
    result.fold(
      (Failure failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (WalletAccount account) => emit(state.copyWith(
        status: WalletStatus.success,
        currentAccount: account,
      )),
    );
  }

  Future<void> _onImportRequested(
    WalletImportRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));
    final result = await _importWallet(ImportWalletParams(
      mnemonic: event.mnemonic,
      pin: event.pin,
    ));
    result.fold(
      (Failure failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (WalletAccount account) => emit(state.copyWith(
        status: WalletStatus.success,
        currentAccount: account,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    WalletLogoutRequested event,
    Emitter<WalletState> emit,
  ) async {
    await _walletRepository.deleteWallet();
    emit(const WalletState());
  }
}