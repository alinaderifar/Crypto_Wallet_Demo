import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/chain_config.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/transaction.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_event.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_state.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/transaction_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/transaction_event.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/transaction_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChainBloc>().add(const ChainRefreshRequested());
      context.read<TransactionBloc>().add(const TransactionHistoryRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            onPressed: () => _scanQR(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildChainChip(context),
              const SizedBox(height: 20),
              _buildBalanceCard(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Assets'),
              const SizedBox(height: 12),
              _buildNativeAssetRow(context),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Recent Transactions'),
              const SizedBox(height: 12),
              _buildTransactionSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChainChip(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: BlocSelector<ChainBloc, ChainState, String>(
        selector: (s) => (s.selectedChain ?? ChainConfig.sepolia).name,
        builder: (context, name) {
          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(name, style: const TextStyle(fontSize: 13)),
              ],
            ),
            selected: true,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            labelStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) => GoRouter.of(context).go('/home/chains'),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<ChainBloc, ChainState>(
      buildWhen: (a, b) =>
          a.currentBalance != b.currentBalance ||
          a.status != b.status ||
          a.selectedChain?.chainId != b.selectedChain?.chainId,
      builder: (context, state) {
        final sym = (state.selectedChain ?? ChainConfig.sepolia).symbol;
        final bal = state.currentBalance;
        final title = state.status == ChainStatus.loading && bal == null
            ? 'Loading…'
            : (bal != null ? '$bal $sym' : '—');

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Native Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _BalanceAction(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Send',
                      onTap: () => GoRouter.of(context).go('/home/send'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BalanceAction(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Receive',
                      onTap: () => GoRouter.of(context).go('/home/receive'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BalanceAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Swap',
                      onTap: () {
                        debugPrint('Swap tapped');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.flash_on,
          label: 'Send',
          onTap: () => GoRouter.of(context).go('/home/send'),
        ),
        _QuickAction(
          icon: Icons.download,
          label: 'Receive',
          onTap: () => GoRouter.of(context).go('/home/receive'),
        ),
        _QuickAction(
          icon: Icons.bar_chart,
          label: 'History',
          onTap: () {
            GoRouter.of(context).go('/home');
          },
        ),
        _QuickAction(
          icon: Icons.link_rounded,
          label: 'Connect',
          onTap: () {
            debugPrint('Connect wallet tapped');
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildNativeAssetRow(BuildContext context) {
    return BlocBuilder<ChainBloc, ChainState>(
      buildWhen: (a, b) =>
          a.currentBalance != b.currentBalance ||
          a.selectedChain?.chainId != b.selectedChain?.chainId,
      builder: (context, state) {
        final chain = state.selectedChain ?? ChainConfig.sepolia;
        final bal = state.currentBalance ?? '—';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceLight.withValues(alpha: 0.5)
                : AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.currency_bitcoin_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chain.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      chain.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$bal ${chain.symbol}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionSection(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionFlowStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state.transactions.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceLight.withValues(alpha: 0.5)
                  : AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              state.errorMessage ?? 'No recent transactions for this address.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceLight.withValues(alpha: 0.5)
                : AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < state.transactions.length; i++) ...[
                if (i > 0) const Divider(height: 16),
                _TxRow(
                  tx: state.transactions[i],
                  onTap: () => GoRouter.of(context).go(
                    '/home/transaction/${Uri.encodeComponent(state.transactions[i].txHash)}',
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _scanQR(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR Scanner coming soon')));
  }
}

class _TxRow extends StatelessWidget {
  final TransactionRecord tx;
  final VoidCallback onTap;

  const _TxRow({required this.tx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIn =
        tx.to.isNotEmpty &&
        tx.to.toLowerCase() != tx.from.toLowerCase(); // rough UI hint
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        tx.txHash.length > 14
            ? '${tx.txHash.substring(0, 8)}…${tx.txHash.substring(tx.txHash.length - 6)}'
            : tx.txHash,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
      subtitle: Text(
        _formatTxValue(tx),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
    );
  }

  String _formatTxValue(TransactionRecord tx) {
    if (tx.chainId == 'solana') return 'Signature';
    try {
      final wei = BigInt.parse(tx.value);
      if (wei == BigInt.zero) return '0';
      final base = BigInt.from(10).pow(18);
      final whole = wei ~/ base;
      var frac = wei % base;
      if (frac == BigInt.zero) return '$whole wei (native)';
      var fracStr = frac.toString().padLeft(18, '0');
      fracStr = fracStr.replaceFirst(RegExp(r'0+$'), '');
      return fracStr.isEmpty
          ? '$whole ETH (value)'
          : '$whole.$fracStr ETH (value)';
    } catch (_) {
      return tx.value;
    }
  }
}

class _BalanceAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BalanceAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceLight.withValues(alpha: 0.6)
                : AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
