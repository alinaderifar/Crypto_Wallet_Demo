import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../wallet/domain/usecases/create_wallet.dart' as wallet_uc;
import '../../../wallet/domain/usecases/import_wallet.dart' as wallet_uc;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final wallet_uc.CreateWallet _createWallet;
  final wallet_uc.ImportWallet _importWallet;

  AuthBloc({
    required wallet_uc.CreateWallet createWallet,
    required wallet_uc.ImportWallet importWallet,
  })  : _createWallet = createWallet,
        _importWallet = importWallet,
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
      wallet_uc.ImportWalletParams(
        mnemonic: event.mnemonic,
        pin: event.pin,
      ),
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
    emit(const AuthPinVerified());
  }
}
