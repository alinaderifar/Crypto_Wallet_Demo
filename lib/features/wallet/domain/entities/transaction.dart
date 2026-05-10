import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/types/either.dart';

/// On-chain status for a [TransactionRecord] (distinct from UI flow status in blocs).
enum LedgerTxStatus { pending, confirmed, failed }

/// Represents a single transaction record.
class TransactionRecord extends Equatable {
  final String txHash;
  final String from;
  final String to;
  final String value;
  final String chainId;
  final DateTime timestamp;
  final LedgerTxStatus status;
  final String? errorMessage;

  const TransactionRecord({
    required this.txHash,
    required this.from,
    required this.to,
    required this.value,
    required this.chainId,
    required this.timestamp,
    this.status = LedgerTxStatus.pending,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [txHash];
}

/// Holds transaction parameters before signing.
class TransactionParams {
  final String to;
  final String value;
  final String? data;
  final String chainId;

  const TransactionParams({
    required this.to,
    required this.value,
    this.data,
    required this.chainId,
  });
}

/// Result type for send transaction use case.
class SendResult {
  final String txHash;
  final String chainId;

  const SendResult({required this.txHash, required this.chainId});
}

/// Use case: Send tokens on a specific chain.
class SendTransaction {
  // TODO: Inject wallet provider / chain adapter
  Future<Either<Failure, SendResult>> call({
    required String to,
    required String value,
    required String chainId,
  }) async {
    // TODO: Implement actual transaction building, signing, and broadcasting.
    await Future<void>.delayed(const Duration(seconds: 1));
    return Right(SendResult(
      txHash: '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      chainId: chainId,
    ));
  }
}