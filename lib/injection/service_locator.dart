import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/wallet/data/datasources/chain_remote_data_source.dart';
import '../features/wallet/data/datasources/wallet_local_data_source.dart';
import '../features/wallet/data/repositories/chain_repository_impl.dart';
import '../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../features/wallet/domain/repositories/chain_repository.dart';
import '../features/wallet/domain/repositories/wallet_repository.dart';
import '../features/wallet/domain/usecases/create_wallet.dart';
import '../features/wallet/domain/usecases/import_wallet.dart';
import '../features/wallet/presentation/bloc/chain_bloc.dart';
import '../features/wallet/presentation/bloc/transaction_bloc.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

/// Drives [GoRouter] redirect when wallet session changes.
final ValueNotifier<bool> walletSessionNotifier = ValueNotifier<bool>(false);

/// Initialize the dependency injection container.
Future<void> init() async {
  final walletLocalDataSource = WalletLocalDataSource();
  await walletLocalDataSource.init();
  sl.registerLazySingleton<WalletLocalDataSource>(
    () => walletLocalDataSource,
  );

  final chainRemoteDataSource = ChainRemoteDataSource();
  sl.registerLazySingleton<ChainRemoteDataSource>(
    () => chainRemoteDataSource,
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletLocalDataSource>()),
  );

  sl.registerLazySingleton<ChainRepository>(
    () => ChainRepositoryImpl(sl<ChainRemoteDataSource>()),
  );

  sl.registerLazySingleton<CreateWallet>(
    () => CreateWallet(sl<WalletRepository>()),
  );

  sl.registerLazySingleton<ImportWallet>(
    () => ImportWallet(sl<WalletRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      createWallet: sl<CreateWallet>(),
      importWallet: sl<ImportWallet>(),
    ),
  );

  sl.registerFactory<WalletBloc>(
    () => WalletBloc(
      createWallet: sl<CreateWallet>(),
      importWallet: sl<ImportWallet>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );

  sl.registerFactory<ChainBloc>(
    () => ChainBloc(repository: sl<ChainRepository>()),
  );

  sl.registerFactory<TransactionBloc>(() => TransactionBloc());

  walletSessionNotifier.value = await sl<WalletRepository>().isSessionReady();
}
