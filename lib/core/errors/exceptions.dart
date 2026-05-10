// Custom exceptions for the crypto wallet application.

class MnemonicGenerationException implements Exception {
  final String message;
  const MnemonicGenerationException([this.message = 'Failed to generate mnemonic']);
  @override
  String toString() => 'MnemonicGenerationException: $message';
}

class KeyDerivationException implements Exception {
  final String message;
  const KeyDerivationException([this.message = 'Failed to derive key']);
  @override
  String toString() => 'KeyDerivationException: $message';
}

class EncryptionException implements Exception {
  final String message;
  const EncryptionException([this.message = 'Encryption failed']);
  @override
  String toString() => 'EncryptionException: $message';
}

class DecryptionException implements Exception {
  final String message;
  const DecryptionException([this.message = 'Decryption failed']);
  @override
  String toString() => 'DecryptionException: $message';
}

class StorageException implements Exception {
  final String message;
  final String? key;
  const StorageException(this.message, {this.key});
  @override
  String toString() => 'StorageException($key): $message';
}

class InvalidMnemonicException implements Exception {
  final String message;
  const InvalidMnemonicException([this.message = 'Invalid mnemonic phrase']);
  @override
  String toString() => 'InvalidMnemonicException: $message';
}

class TransactionException implements Exception {
  final String message;
  final String? transactionHash;
  const TransactionException(this.message, {this.transactionHash});
  @override
  String toString() => 'TransactionException: $message';
}

class ChainNotSupportedException implements Exception {
  final String chainId;
  const ChainNotSupportedException(this.chainId);
  @override
  String toString() => 'ChainNotSupportedException: Chain $chainId is not supported';
}

class BiometricException implements Exception {
  final String message;
  const BiometricException([this.message = 'Biometric authentication failed']);
  @override
  String toString() => 'BiometricException: $message';
}

class RpcException implements Exception {
  final String message;
  final int? statusCode;
  const RpcException(this.message, {this.statusCode});
  @override
  String toString() => 'RpcException($statusCode): $message';
}