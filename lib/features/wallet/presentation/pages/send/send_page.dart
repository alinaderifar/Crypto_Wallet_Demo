import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_cubit.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/entities/chain_config.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/repositories/chain_repository.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/usecases/send_native_eth.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_bloc.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_event.dart';
import 'package:crypto_wallet_demo/features/wallet/presentation/bloc/chain_state.dart';
import 'package:crypto_wallet_demo/injection/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SendPage extends StatefulWidget {
  final String? tokenAddress;

  const SendPage({super.key, this.tokenAddress});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showFeeBreakdown = false;
  String? _feeEstimate;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChainBloc>().add(const ChainRefreshRequested());
      _loadFeeEstimate();
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadFeeEstimate() async {
    final chain =
        context.read<ChainBloc>().state.selectedChain ?? ChainConfig.sepolia;
    final account = await sl<WalletRepository>().getCurrentAccount();
    if (!mounted || account == null) return;
    final from = account.addressForChain(chain.chainId);
    try {
      final fee = await sl<ChainRepository>().estimateFee(
        from: from,
        to: from,
        value: '0',
      );
      if (mounted) setState(() => _feeEstimate = fee);
    } catch (_) {
      if (mounted) setState(() => _feeEstimate = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildChainSelector(context),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Address',
                    hintText: '0x0000...0000',
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 10) return 'Invalid address';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BlocSelector<ChainBloc, ChainState, String>(
                  selector: (s) =>
                      (s.selectedChain ?? ChainConfig.sepolia).symbol,
                  builder: (context, symbol) {
                    return TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: '0.00',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        suffix: Text(
                          symbol,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter an amount';
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: BlocBuilder<ChainBloc, ChainState>(
                    buildWhen: (a, b) =>
                        a.currentBalance != b.currentBalance ||
                        a.selectedChain?.chainId != b.selectedChain?.chainId,
                    builder: (context, state) {
                      final sym =
                          (state.selectedChain ?? ChainConfig.sepolia).symbol;
                      final bal = state.currentBalance;
                      if (bal == null) {
                        return Text(
                          'Balance: —',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        );
                      }
                      return Text(
                        'Balance: $bal $sym',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeePreview(),
                const SizedBox(height: 32),
                BlocBuilder<ConnectivityCubit, ConnectivityState>(
                  buildWhen: (a, b) =>
                      a.hasChecked != b.hasChecked || a.online != b.online,
                  builder: (context, conn) {
                    final disabled =
                        _sending || (conn.hasChecked && !conn.online);
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: disabled ? null : _onSendPressed,
                        child: _sending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChainSelector(BuildContext context) {
    return InkWell(
      onTap: () => GoRouter.of(context).go('/home/chains'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceLight.withValues(alpha: 0.6)
              : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                BlocSelector<ChainBloc, ChainState, String>(
                  selector: (state) =>
                      (state.selectedChain ?? ChainConfig.sepolia).name,
                  builder: (context, chainName) {
                    return Text(
                      chainName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildFeePreview() {
    final fee = _feeEstimate ?? '—';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showFeeBreakdown = !_showFeeBreakdown),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Network Fee (est.)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                BlocSelector<ChainBloc, ChainState, String>(
                  selector: (s) =>
                      (s.selectedChain ?? ChainConfig.sepolia).symbol,
                  builder: (context, sym) {
                    return Text(
                      '~$fee $sym',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                ),
                Icon(
                  _showFeeBreakdown ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
          if (_showFeeBreakdown) ...[
            const Divider(height: 20),
            _buildFeeRow('Gas limit', '21,000'),
            _buildFeeRow('Type', 'Legacy gas price'),
            const Divider(height: 20),
            BlocSelector<ChainBloc, ChainState, String>(
              selector: (s) => (s.selectedChain ?? ChainConfig.sepolia).symbol,
              builder: (context, sym) {
                return _buildFeeRow(
                  'Total fee (est.)',
                  '~$fee $sym',
                  isBold: true,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _promptPin() async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm with PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Wallet PIN',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return pin;
  }

  Future<void> _onSendPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final conn = context.read<ConnectivityCubit>().state;
    if (conn.hasChecked && !conn.online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to the internet to send.')),
      );
      return;
    }

    final chain = context.read<ChainBloc>().state.selectedChain;
    if (chain != null && !chain.isEVM) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Native send is only enabled for EVM networks in this build.',
          ),
        ),
      );
      return;
    }

    final pin = await _promptPin();
    if (!mounted || pin == null || pin.length < 4) return;

    setState(() => _sending = true);
    final result = await sl<SendNativeEth>()(
      SendNativeEthParams(
        to: _recipientController.text.trim(),
        amountEth: _amountController.text.trim(),
        pin: pin,
      ),
    );
    if (!mounted) return;
    setState(() => _sending = false);

    result.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (r) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submitted. Tx: ${r.txHash}')));
        context.read<ChainBloc>().add(const ChainRefreshRequested());
      },
    );
  }
}
