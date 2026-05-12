// ─── App-Wide Constants ────────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Crypto Wallet';
  static const String appVersion = '0.1.0';
  static const String appBuildNumber = '1';

  // Supported chains (mainnet)
  static const String ethereumChainId = '1';
  static const String polygonChainId = '137';
  static const String solanaChainId = 'solana';

  // RPC endpoints (fallback / public — replace with dedicated endpoints in production)
  static const String ethereumRpcUrl = 'https://eth.llamarpc.com';
  static const String polygonRpcUrl = 'https://polygon.llamarpc.com';
  static const String solanaRpcUrl = 'https://api.mainnet-beta.solana.com';

  // WalletConnect project ID — replace with your own from walletconnect.com
  static const String walletConnectProjectId = 'YOUR_PROJECT_ID_HERE';

  // Storage keys
  static const String mnemonicKey = 'mnemonic';
  static const String selectedChainIdKey = 'selected_chain_id';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);

  // Number formatting
  static const int maxDecimalPlaces = 6;
}
