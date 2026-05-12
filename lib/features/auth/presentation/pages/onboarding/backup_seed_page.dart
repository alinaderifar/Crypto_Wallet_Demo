import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/app/theme/app_palette.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:crypto_wallet_demo/injection/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackupSeedPage extends StatefulWidget {
  const BackupSeedPage({super.key});

  @override
  State<BackupSeedPage> createState() => _BackupSeedPageState();
}

class _BackupSeedPageState extends State<BackupSeedPage> {
  bool _confirmedBackup = false;
  bool _loading = true;
  String? _error;
  List<String> _mnemonicWords = const [];
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadStarted) return;
    _loadStarted = true;
    _loadMnemonic();
  }

  Future<void> _loadMnemonic() async {
    final extra = GoRouterState.of(context).extra;
    final pin = extra is String ? extra : null;
    if (pin == null || pin.length < 4) {
      setState(() {
        _loading = false;
        _error =
            'Missing PIN. Go back, create your wallet again, and continue from this screen.';
      });
      return;
    }

    final phrase = await sl<WalletRepository>().unlockMnemonic(pin);
    if (!mounted) return;
    if (phrase == null || phrase.trim().isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'Could not decrypt your recovery phrase. Check your PIN context.';
      });
      return;
    }

    final words = phrase.trim().split(RegExp(r'\s+'));
    setState(() {
      _mnemonicWords = words;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _mnemonicWords = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Backup Your Recovery Phrase',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Write down these ${_mnemonicWords.isEmpty ? 12 : _mnemonicWords.length} words in order and store them in a safe place.\n\n'
                'Never share your recovery phrase with anyone. '
                'If you lose it, you will lose access to your wallet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 16),
              ],
              if (!_loading && _error == null && _mnemonicWords.isNotEmpty)
                _buildSeedGrid(),
              const SizedBox(height: 24),
              _buildWarningCard(),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text(
                  'I have written down my recovery phrase in a safe place',
                ),
                value: _confirmedBackup,
                onChanged: (v) => setState(() => _confirmedBackup = v ?? false),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue ? _onContinue : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  bool get _canContinue =>
      _confirmedBackup &&
      !_loading &&
      _error == null &&
      _mnemonicWords.isNotEmpty;

  Widget _buildSeedGrid() {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chipWidth = (constraints.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_mnemonicWords.length, (index) {
              return SizedBox(
                width: chipWidth,
                child: _buildWordChip(index + 1, _mnemonicWords[index]),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildWordChip(int number, String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$number.',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            word,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Never store your recovery phrase digitally. Write it on paper and keep it in a secure, offline location.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    GoRouter.of(context).go('/onboarding/verify');
  }
}
