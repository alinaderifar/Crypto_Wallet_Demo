import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/chain_config.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_event.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ChainSelectPage extends StatelessWidget {
  const ChainSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Network'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: BlocBuilder<ChainBloc, ChainState>(
        buildWhen: (prev, curr) =>
            prev.selectedChain?.chainId != curr.selectedChain?.chainId ||
            prev.status != curr.status,
        builder: (context, state) {
          final selectedChainId = state.selectedChain?.chainId;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _buildSection(context, 'Main Networks'),
              ...ChainConfig.supportedChains.map((chain) => _buildChainTile(
                    context,
                    chain,
                    chain.chainId == selectedChainId,
                    onTap: () {
                      context.read<ChainBloc>().add(
                            ChainChanged(chain.chainId),
                          );
                      GoRouter.of(context).go('/home');
                    },
                  )),
              _buildSection(context, 'Test Networks'),
              ...ChainConfig.testChains.map((chain) => _buildChainTile(
                    context,
                    chain,
                    chain.chainId == selectedChainId,
                    onTap: () {
                      context.read<ChainBloc>().add(
                            ChainChanged(chain.chainId),
                          );
                      GoRouter.of(context).go('/home');
                    },
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
      ),
    );
  }

  Widget _buildChainTile(
    BuildContext context,
    ChainConfig chain,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : null,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            chain.symbol,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: Text(
        chain.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        chain.chainId,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
      selectedTileColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.06)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
