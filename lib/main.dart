import 'package:crypto_wallet_demo/core/network/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'features/wallet/presentation/bloc/chain_bloc.dart';
import 'features/wallet/presentation/bloc/transaction_bloc.dart';
import 'injection/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System chrome settings
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await di.init();

  runApp(const CryptoWalletApp());
}

class CryptoWalletApp extends StatelessWidget {
  const CryptoWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>.value(
          value: di.sl<ConnectivityCubit>(),
        ),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<WalletBloc>()),
        BlocProvider(create: (_) => di.sl<ChainBloc>()),
        BlocProvider(create: (_) => di.sl<TransactionBloc>()),
      ],
      child: const App(),
    );
  }
}
