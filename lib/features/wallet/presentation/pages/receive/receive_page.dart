import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/app/theme/app_palette.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/chain_config.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_state.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/wallet_state.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocBuilder<WalletBloc, WalletState>(
            builder: (context, w) {
              return BlocBuilder<ChainBloc, ChainState>(
                builder: (context, c) {
                  final chain = c.selectedChain ?? ChainConfig.sepolia;
                  final account = w.currentAccount;
                  final address = account == null
                      ? ''
                      : account.addressForChain(chain.chainId);
                  final ready = address.isNotEmpty;

                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code,
                            size: 120,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!ready)
                        Text(
                          'Wallet not loaded yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else ...[
                        _buildAddressCard(context, address, chain.symbol),
                        const SizedBox(height: 24),
                        _buildNetworkCard(context, chain.name),
                      ],
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    String address,
    String symbol,
  ) {
    final palette = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Text(
            'Your $symbol Address',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          SelectableText(
            _truncateAddress(address),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: address));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_all_rounded, size: 18),
            label: const Text('Copy Address'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(BuildContext context, String networkName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Network: $networkName. Share this address only with trusted parties.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length > 16) {
      return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
    }
    return address;
  }
}
