import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/transaction.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

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
              // Chain selector chip
              _buildChainChip(context),
              const SizedBox(height: 20),
              // Main balance card
              _buildBalanceCard(context),
              const SizedBox(height: 24),
              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),
              // Token list header
              _buildSectionHeader(context, 'Assets'),
              const SizedBox(height: 12),
              // Token list placeholder
              _buildTokenListPlaceholder(context),
              const SizedBox(height: 24),
              // Recent transactions header
              _buildSectionHeader(context, 'Recent Transactions'),
              const SizedBox(height: 12),
              // Transaction list placeholder
              _buildTransactionListPlaceholder(context),
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
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text('Ethereum', style: TextStyle(fontSize: 13)),
          ],
        ),
        selected: true,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        onSelected: (_) => GoRouter.of(context).go('/home/chains'),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
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
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$12,458.32',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                    // TODO: Navigate to swap page
                    debugPrint('Swap tapped');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
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
            // TODO: Show Web3Modal wallet connection
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildTokenListPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceLight.withOpacity(0.5)
            : AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Icon(Icons.currency_bitcoin_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ETH',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(
                  'Ethereum',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('3.456789 ETH',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('\$7,234.56',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceLight.withOpacity(0.5)
            : AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _TransactionItem(
            title: 'Sent ETH',
            subtitle: '0x742d...3f5a',
            amount: '-0.5 ETH',
            status: LedgerTxStatus.confirmed,
          ),
          const Divider(height: 24),
          _TransactionItem(
            title: 'Received ETH',
            subtitle: '0x8912...7b3c',
            amount: '+1.2 ETH',
            status: LedgerTxStatus.confirmed,
          ),
        ],
      ),
    );
  }

  void _scanQR(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scanner coming soon')),
    );
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
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
                ? AppColors.surfaceLight.withOpacity(0.6)
                : AppColors.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final LedgerTxStatus status;

  const _TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith('+');
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPositive
              ? AppColors.success.withOpacity(0.12)
              : AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isPositive ? AppColors.success : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status == LedgerTxStatus.confirmed
                  ? AppColors.success
                  : status == LedgerTxStatus.pending
                      ? AppColors.warning
                      : AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status == LedgerTxStatus.confirmed
                ? 'Confirmed'
                : status == LedgerTxStatus.pending
                    ? 'Pending'
                    : 'Failed',
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.success : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '≈ \$1,234.56',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}