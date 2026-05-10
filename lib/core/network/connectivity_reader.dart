import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction for [ConnectivityCubit] and tests.
abstract class ConnectivityReader {
  Future<bool> get isConnected;

  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}
