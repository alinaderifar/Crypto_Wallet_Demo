import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:crypto_wallet_demo/core/constants/app_constants.dart';
import 'package:crypto_wallet_demo/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:crypto_wallet_demo/injection/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection(context, 'GENERAL'),
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.dark_mode,
            title: 'Appearance',
            subtitle: 'Light / Dark / System',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Transaction alerts, price alerts',
            onTap: () {},
          ),
          _buildSection(context, 'SECURITY'),
          _SettingsTile(
            icon: Icons.security,
            title: 'Change PIN',
            subtitle: 'Update your wallet PIN',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Auth',
            subtitle: 'Enable Face ID / Fingerprint',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          _SettingsTile(
            icon: Icons.warning_amber_rounded,
            title: 'Security Center',
            subtitle: 'Review recent activity',
            onTap: () {},
          ),
          _buildSection(context, 'WALLET'),
          _SettingsTile(
            icon: Icons.wallet_outlined,
            title: 'Connected Wallets',
            subtitle: 'Manage external wallet connections',
            onTap: () {
              // TODO: Navigate to wallet connect management
            },
          ),
          _SettingsTile(
            icon: Icons.visibility,
            title: 'Wallet Visibility',
            subtitle: 'Toggle hidden wallets',
            onTap: () {},
          ),
          _buildSection(context, 'ABOUT'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version ${AppConstants.appVersion}',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _launchUrl('https://example.com/terms'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _launchUrl('https://example.com/privacy'),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQ & Contact us',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () => _onLogout(context),
              child: const Text(
                'Log Out',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onLogout(BuildContext context) async {
    await sl<WalletRepository>().deleteWallet();
    walletSessionNotifier.value = false;
    if (context.mounted) {
      GoRouter.of(context).go('/onboarding');
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}
