import 'package:equatable/equatable.dart';

sealed class ChainEvent extends Equatable {
  const ChainEvent();
  @override
  List<Object?> get props => [];
}

class ChainChanged extends ChainEvent {
  final String chainId;
  const ChainChanged(this.chainId);
  @override
  List<Object> get props => [chainId];
}

class ChainRefreshRequested extends ChainEvent {
  const ChainRefreshRequested();
}
