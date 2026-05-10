import 'package:equatable/equatable.dart';

/// Represents a blockchain network supported by the wallet.
class ChainConfig extends Equatable {
  final String chainId;
  final String name;
  final String symbol;
  final int rpcPort;
  final String rpcUrl;
  final bool isEVM;
  final String? logoUrl;
  final String? blockExplorerUrl;

  /// Optional Blockscout-compatible `.../api` root for account tx lists (no API key).
  final String? accountExplorerApiBase;

  const ChainConfig({
    required this.chainId,
    required this.name,
    required this.symbol,
    required this.rpcPort,
    required this.rpcUrl,
    required this.isEVM,
    this.logoUrl,
    this.blockExplorerUrl,
    this.accountExplorerApiBase,
  });

  /// Ethereum Mainnet
  static const ethereumMainnet = ChainConfig(
    chainId: '1',
    name: 'Ethereum',
    symbol: 'ETH',
    rpcPort: 443,
    rpcUrl: 'https://eth.llamarpc.com',
    isEVM: true,
    blockExplorerUrl: 'https://etherscan.io',
  );

  /// Polygon Mainnet
  static const polygonMainnet = ChainConfig(
    chainId: '137',
    name: 'Polygon',
    symbol: 'POL',
    rpcPort: 443,
    rpcUrl: 'https://polygon.llamarpc.com',
    isEVM: true,
    blockExplorerUrl: 'https://polygonscan.com',
  );

  /// Sepolia Testnet (default for new wallets in this demo)
  static const sepolia = ChainConfig(
    chainId: '11155111',
    name: 'Sepolia',
    symbol: 'ETH',
    rpcPort: 443,
    rpcUrl: 'https://ethereum-sepolia-rpc.publicnode.com',
    isEVM: true,
    blockExplorerUrl: 'https://sepolia.etherscan.io',
    accountExplorerApiBase: 'https://eth-sepolia.blockscout.com/api',
  );

  /// Solana Mainnet
  static const solanaMainnet = ChainConfig(
    chainId: 'solana',
    name: 'Solana',
    symbol: 'SOL',
    rpcPort: 443,
    rpcUrl: 'https://api.mainnet-beta.solana.com',
    isEVM: false,
    blockExplorerUrl: 'https://solscan.io',
  );

  /// Supported chains shown in the app (Sepolia first for safer demos).
  static const supportedChains = [
    sepolia,
    ethereumMainnet,
    polygonMainnet,
    solanaMainnet,
  ];

  static ChainConfig? fromChainId(String chainId) {
    for (final chain in supportedChains) {
      if (chain.chainId == chainId) return chain;
    }
    return null;
  }

  @override
  List<Object?> get props => [chainId, rpcUrl, accountExplorerApiBase];

  @override
  String toString() => 'ChainConfig($name [$chainId])';
}
