import 'package:equatable/equatable.dart';

import '../../domain/entities/chain_config.dart';

enum ChainStatus { initial, loading, success, error }

class ChainState extends Equatable {
  final ChainStatus status;
  final ChainConfig? selectedChain;
  final String? currentBalance;
  final String? errorMessage;

  const ChainState({
    this.status = ChainStatus.initial,
    this.selectedChain,
    this.currentBalance,
    this.errorMessage,
  });

  ChainState copyWith({
    ChainStatus? status,
    ChainConfig? selectedChain,
    String? currentBalance,
    String? errorMessage,
  }) {
    return ChainState(
      status: status ?? this.status,
      selectedChain: selectedChain ?? this.selectedChain,
      currentBalance: currentBalance ?? this.currentBalance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedChain,
    currentBalance,
    errorMessage,
  ];
}
