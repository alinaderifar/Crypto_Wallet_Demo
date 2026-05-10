import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackupSeedPage extends StatefulWidget {
  const BackupSeedPage({super.key});

  @override
  State<BackupSeedPage> createState() => _BackupSeedPageState();
}

class _BackupSeedPageState extends State<BackupSeedPage> {
  bool _confirmedBackup = false;

  // TODO: Get actual mnemonic from KeyManager
  final List<String> _mnemonicWords = const [
    'abandon', 'abandon', 'abandon', 'abandon',
    'abandon', 'abandon', 'abandon', 'abandon',
    'abandon', 'abandon', 'abandon', 'about',
  ];

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
                'Write down these 12 words in order and store them in a safe place.\n\n'
                '⚠️ Never share your recovery phrase with anyone. '
                'If you lose it, you will lose access to your wallet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              // Seed phrase grid
              _buildSeedGrid(),
              const SizedBox(height: 24),
              // Warning card
              _buildWarningCard(),
              const SizedBox(height: 24),
              // Checkbox
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
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirmedBackup ? _onContinue : null,
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

  Widget _buildSeedGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceLight.withOpacity(0.6)
            : AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_mnemonicWords.length, (index) {
          return _buildWordChip(index + 1, _mnemonicWords[index]);
        }),
      ),
    );
  }

  Widget _buildWordChip(int number, String word) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 24),
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