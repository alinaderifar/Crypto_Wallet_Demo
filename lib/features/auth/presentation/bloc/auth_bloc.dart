import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../wallet/domain/usecases/create_wallet.dart' as wallet_uc;
import '../../../wallet/domain/usecases/import_wallet.dart' as wallet_uc;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final wallet_uc.CreateWallet _createWallet;
  final wallet_uc.ImportWallet _importWallet;
  final WalletRepository _walletRepository;

  AuthBloc({
    required wallet_uc.CreateWallet createWallet,
    required wallet_uc.ImportWallet importWallet,
    required WalletRepository walletRepository,
  }) : _createWallet = createWallet,
       _importWallet = importWallet,
       _walletRepository = walletRepository,
       super(const AuthInitial()) {
    on<AuthCreateWallet>(_onCreateWallet);
    on<AuthImportWallet>(_onImportWallet);
    on<AuthVerifyPin>(_onVerifyPin);
  }

  Future<void> _onCreateWallet(
    AuthCreateWallet event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _createWallet(
      wallet_uc.CreateWalletParams(pin: event.pin),
    );
    result.fold(
      (Failure failure) => emit(AuthFailureState(failure)),
      (_) => emit(const AuthWalletCreated()),
    );
  }

  Future<void> _onImportWallet(
    AuthImportWallet event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _importWallet(
      wallet_uc.ImportWalletParams(mnemonic: event.mnemonic, pin: event.pin),
    );
    result.fold(
      (Failure failure) => emit(AuthFailureState(failure)),
      (_) => emit(const AuthWalletImported()),
    );
  }

  Future<void> _onVerifyPin(
    AuthVerifyPin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final ok = await _walletRepository.verifyPin(event.pin);
    if (ok) {
      emit(const AuthPinVerified());
    } else {
      emit(AuthFailureState(WalletFailure(message: 'Incorrect PIN')));
    }
  }
}
