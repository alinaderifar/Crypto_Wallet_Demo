import 'package:flutter/foundation.dart';

/// WalletConnect / Web3Modal integration service.
///
/// This service handles:
/// - Connecting external wallets (MetaMask, Trust Wallet, Coinbase Wallet, etc.)
/// - Managing multiple wallet connections
/// - QR code-based pairing for mobile wallets
/// - Chain switching via wallet_switchEthereumChain
/// - Session persistence across app restarts
///
/// This is a placeholder — full integration requires WalletConnect project ID
/// from https://cloud.walletconnect.com/
class WalletConnectService {
  // TODO: Initialize Web3ModalFlutter with projectId
  // final W3MService _w3mService = W3MService(
  //   projectId: AppConstants.walletConnectProjectId,
  //   metadata: PairingMetadata(
  //     name: 'Crypto Wallet Demo',
  //     description: 'A multi-chain crypto wallet',
  //     url: 'https://example.com',
  //     icons: ['https://example.com/icon.png'],
  //   ),
  // );

  /// Whether a wallet is currently connected via WalletConnect.
  bool get isConnected => false; // TODO: Implement

  /// The connected wallet's address.
  String? get connectedAddress => null; // TODO: Implement

  /// Initialize the WalletConnect service.
  Future<void> init() async {
    // TODO: Call _w3mService.init()
    debugPrint('WalletConnectService: init (placeholder)');
  }

  /// Open the wallet connection modal to select a wallet.
  Future<void> connectWallet() async {
    // TODO: Show Web3Modal connector modal
    debugPrint('WalletConnectService: connectWallet (placeholder)');
  }

  /// Disconnect the current wallet.
  Future<void> disconnectWallet() async {
    // TODO: Disconnect via Web3Modal
    debugPrint('WalletConnectService: disconnectWallet (placeholder)');
  }

  /// Get the Ethereum/EVM provider for the connected wallet.
  // dynamic get ethereumProvider {
  //   TODO: Return Web3Provider or similar
  // }

  /// Switch the connected wallet's active chain.
  Future<void> switchChain(String chainId) async {
    // TODO: Use wallet_switchEthereumChain
    debugPrint('WalletConnectService: switchChain to $chainId (placeholder)');
  }
}

final walletConnectService = WalletConnectService();
