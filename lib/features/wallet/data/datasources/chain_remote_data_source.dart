import 'package:dio/dio.dart';

import '../../domain/entities/chain_config.dart';
import '../../domain/entities/transaction.dart';

/// Data source for fetching blockchain data via RPC endpoints.
///
/// Uses Dio for HTTP requests with connection pooling and timeout handling.
class ChainRemoteDataSource {
  final Dio _dio;

  ChainRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 25),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  Future<dynamic> _evmRpc(
    ChainConfig chain,
    String method,
    List<dynamic> params,
  ) async {
    final res = await _dio.post<dynamic>(
      chain.rpcUrl,
      data: <String, dynamic>{
        'jsonrpc': '2.0',
        'id': 1,
        'method': method,
        'params': params,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid RPC response');
    }
    final err = data['error'];
    if (err != null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: err.toString(),
      );
    }
    return data['result'];
  }

  /// Fetches the balance for an address on the given chain.
  Future<String> getBalance({
    required String address,
    required ChainConfig chain,
  }) async {
    if (chain.isEVM) {
      final hex =
          await _evmRpc(chain, 'eth_getBalance', [
                _normalize0x(address),
                'latest',
              ])
              as String;
      return _weiHexToEthDisplay(hex);
    }
    final res = await _dio.post<dynamic>(
      chain.rpcUrl,
      data: <String, dynamic>{
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getBalance',
        'params': [
          address,
          <String, String>{'commitment': 'confirmed'},
        ],
      },
    );
    final data = res.data as Map<String, dynamic>;
    final err = data['error'];
    if (err != null) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: err.toString(),
      );
    }
    final value = (data['result'] as Map<String, dynamic>)['value'] as int;
    final sol = value / 1e9;
    return sol.toStringAsFixed(6);
  }

  /// Fetches recent transactions for an address.
  Future<List<TransactionRecord>> getTransactions({
    required String address,
    required ChainConfig chain,
  }) async {
    if (chain.isEVM) {
      final base = chain.accountExplorerApiBase;
      if (base == null) return [];
      final uri =
          '$base?module=account&action=txlist&address=${_normalize0x(address)}&page=1&offset=20&sort=desc';
      final res = await _dio.get<dynamic>(uri);
      final data = res.data;
      if (data is! Map<String, dynamic>) return [];
      final status = data['status']?.toString();
      final list = data['result'];
      if (status != '1' || list is! List<dynamic>) return [];
      return list.map((dynamic raw) {
        final m = raw as Map<String, dynamic>;
        final ts = int.tryParse(m['timeStamp']?.toString() ?? '') ?? 0;
        final success = (m['txreceipt_status']?.toString() ?? '1') == '1';
        return TransactionRecord(
          txHash: m['hash'] as String? ?? '',
          from: m['from'] as String? ?? '',
          to: m['to'] as String? ?? '',
          value: m['value']?.toString() ?? '0',
          chainId: chain.chainId,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            ts * 1000,
            isUtc: true,
          ),
          status: success ? LedgerTxStatus.confirmed : LedgerTxStatus.failed,
        );
      }).toList();
    }
    final res = await _dio.post<dynamic>(
      chain.rpcUrl,
      data: <String, dynamic>{
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'getSignaturesForAddress',
        'params': [
          address,
          <String, dynamic>{'limit': 20},
        ],
      },
    );
    final data = res.data as Map<String, dynamic>;
    final err = data['error'];
    if (err != null) return [];
    final list = data['result'] as List<dynamic>? ?? [];
    return list.map((dynamic raw) {
      final m = raw as Map<String, dynamic>;
      final sig = m['signature'] as String? ?? '';
      final block = m['blockTime'] as int?;
      return TransactionRecord(
        txHash: sig,
        from: address,
        to: '',
        value: '0',
        chainId: chain.chainId,
        timestamp: block != null
            ? DateTime.fromMillisecondsSinceEpoch(block * 1000, isUtc: true)
            : DateTime.now().toUtc(),
        status: LedgerTxStatus.confirmed,
      );
    }).toList();
  }

  /// Estimates the network fee for a simple native transfer (EVM legacy gas price path).
  Future<String> estimateFee({
    required String from,
    required String to,
    required String value,
    required ChainConfig chain,
  }) async {
    if (chain.isEVM) {
      final gasHex =
          await _evmRpc(chain, 'eth_gasPrice', <dynamic>[]) as String;
      final gasWei = BigInt.parse(_strip0x(gasHex), radix: 16);
      final gasLimit = BigInt.from(21000);
      final feeWei = gasWei * gasLimit;
      return _weiBigIntToEthDisplay(feeWei);
    }
    return '0.000005';
  }

  /// Broadcasts a signed EVM transaction (hex, with or without 0x).
  Future<String> sendSignedTransaction({
    required String signedTx,
    required ChainConfig chain,
  }) async {
    if (!chain.isEVM) {
      throw UnsupportedError(
        'Native broadcast is implemented for EVM only in this demo.',
      );
    }
    final hex = signedTx.startsWith('0x') ? signedTx : '0x$signedTx';
    final hash =
        await _evmRpc(chain, 'eth_sendRawTransaction', [hex]) as String;
    return hash;
  }
}

String _normalize0x(String address) {
  final a = address.trim();
  if (a.startsWith('0x') || a.startsWith('0X')) return a;
  return '0x$a';
}

String _strip0x(String hex) {
  if (hex.startsWith('0x') || hex.startsWith('0X')) return hex.substring(2);
  return hex;
}

String _weiHexToEthDisplay(String hex) {
  final v = BigInt.parse(_strip0x(hex), radix: 16);
  return _weiBigIntToEthDisplay(v);
}

String _weiBigIntToEthDisplay(BigInt wei) {
  if (wei == BigInt.zero) return '0';
  final base = BigInt.from(10).pow(18);
  final whole = wei ~/ base;
  var frac = wei % base;
  if (frac == BigInt.zero) return whole.toString();
  var fracStr = frac.toString().padLeft(18, '0');
  fracStr = fracStr.replaceFirst(RegExp(r'0+$'), '');
  if (fracStr.isEmpty) return whole.toString();
  return '$whole.$fracStr';
}
