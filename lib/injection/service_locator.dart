import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/network/connectivity_cubit.dart';
import '../core/network/connectivity_reader.dart';
import '../core/network/network_info.dart';
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
import '../features/wallet/domain/usecases/send_native_eth.dart';
import '../features/wallet/presentation/bloc/chain_bloc.dart';
import '../features/wallet/presentation/bloc/transaction_bloc.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

/// Drives [GoRouter] redirect when wallet session changes.
final ValueNotifier<bool> walletSessionNotifier = ValueNotifier<bool>(false);

/// Initialize the dependency injection container.
Future<void> init() async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl<Connectivity>()));
  sl.registerLazySingleton<ConnectivityReader>(() => sl<NetworkInfo>());
  sl.registerLazySingleton<ConnectivityCubit>(
    () => ConnectivityCubit(sl<ConnectivityReader>()),
  );

  await Hive.initFlutter();

  final walletLocalDataSource = WalletLocalDataSource();
  await walletLocalDataSource.init();
  sl.registerLazySingleton<WalletLocalDataSource>(() => walletLocalDataSource);

  final chainRemoteDataSource = ChainRemoteDataSource();
  sl.registerLazySingleton<ChainRemoteDataSource>(() => chainRemoteDataSource);

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<WalletLocalDataSource>()),
  );

  sl.registerLazySingleton<ChainRepository>(
    () => ChainRepositoryImpl(
      sl<ChainRemoteDataSource>(),
      sl<WalletLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<CreateWallet>(
    () => CreateWallet(sl<WalletRepository>()),
  );

  sl.registerLazySingleton<ImportWallet>(
    () => ImportWallet(sl<WalletRepository>()),
  );

  sl.registerLazySingleton<SendNativeEth>(
    () => SendNativeEth(sl<WalletRepository>(), sl<ChainRepository>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      createWallet: sl<CreateWallet>(),
      importWallet: sl<ImportWallet>(),
      walletRepository: sl<WalletRepository>(),
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
    () => ChainBloc(
      repository: sl<ChainRepository>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );

  sl.registerFactory<TransactionBloc>(
    () => TransactionBloc(
      chainRepository: sl<ChainRepository>(),
      walletRepository: sl<WalletRepository>(),
    ),
  );

  walletSessionNotifier.value = await sl<WalletRepository>().isSessionReady();

  await sl<ConnectivityCubit>().start();
}
