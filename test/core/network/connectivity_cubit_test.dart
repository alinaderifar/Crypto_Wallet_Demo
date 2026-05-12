import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_cubit.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_reader.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeReader implements ConnectivityReader {
  _FakeReader({required this.online, Stream<List<ConnectivityResult>>? stream})
    : _stream = stream ?? Stream<List<ConnectivityResult>>.empty();

  bool online;
  final Stream<List<ConnectivityResult>> _stream;

  @override
  Future<bool> get isConnected async => online;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _stream;
}

void main() {
  test('start emits offline when reader reports disconnected', () async {
    final reader = _FakeReader(online: false);
    final cubit = ConnectivityCubit(reader);
    await cubit.start();
    expect(cubit.state.hasChecked, isTrue);
    expect(cubit.state.online, isFalse);
    expect(cubit.state.shouldShowOfflineBanner, isTrue);
    await cubit.close();
  });

  test('stream refresh updates state', () async {
    final controller = StreamController<List<ConnectivityResult>>.broadcast();
    final reader = _FakeReader(online: true, stream: controller.stream);
    final cubit = ConnectivityCubit(reader);
    await cubit.start();
    expect(cubit.state.online, isTrue);

    reader.online = false;
    controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.online, isFalse);

    await cubit.close();
    await controller.close();
  });
}
