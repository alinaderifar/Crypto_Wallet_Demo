import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_cubit.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_reader.dart';
import 'package:crypto_wallet_demo/core/network/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Offline UI without [ConnectivityCubit.start] / streams (widget tests can hang on stream + pump timing).
class _OfflineTestCubit extends ConnectivityCubit {
  _OfflineTestCubit() : super(_UnusedReader()) {
    emit(const ConnectivityState(online: false, hasChecked: true));
  }
}

class _UnusedReader implements ConnectivityReader {
  @override
  Future<bool> get isConnected =>
      throw UnsupportedError('unused in offline banner widget test');

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream<List<ConnectivityResult>>.empty();
}

void main() {
  testWidgets('OfflineBanner builds when cubit reports offline', (
    tester,
  ) async {
    final cubit = _OfflineTestCubit();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>.value(
          value: cubit,
          child: const Scaffold(body: OfflineBanner()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(cubit.state.shouldShowOfflineBanner, isTrue);

    await cubit.close();
  });
}
