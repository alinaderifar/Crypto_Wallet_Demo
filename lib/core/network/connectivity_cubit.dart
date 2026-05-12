import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'connectivity_reader.dart';

/// Tracks device connectivity for UI (banner, disabled actions).
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._reader) : super(ConnectivityState.initial());

  final ConnectivityReader _reader;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> start() async {
    await _refresh();
    _subscription ??= _reader.onConnectivityChanged.listen((_) => _refresh());
  }

  Future<void> _refresh() async {
    final online = await _reader.isConnected;
    emit(ConnectivityState(online: online, hasChecked: true));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class ConnectivityState {
  /// Whether the device appears to have a usable connection.
  final bool online;

  /// False until the first [checkConnectivity] completes.
  final bool hasChecked;

  const ConnectivityState({required this.online, required this.hasChecked});

  factory ConnectivityState.initial() =>
      const ConnectivityState(online: true, hasChecked: false);

  bool get shouldShowOfflineBanner => hasChecked && !online;
}
