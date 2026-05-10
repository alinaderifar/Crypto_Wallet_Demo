import 'package:connectivity_plus/connectivity_plus.dart';

import 'connectivity_reader.dart';

/// Network info utility — checks connectivity before blockchain calls.
class NetworkInfo implements ConnectivityReader {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return false;
    return !results.every((r) => r == ConnectivityResult.none);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
