import 'package:crypto_wallet_demo/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'Welcome to\nCrypto Wallet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Your secure, multi-chain wallet for the decentralized web.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
              ),
              const Spacer(flex: 2),
              // Feature cards
              _FeatureCard(
                icon: Icons.lock_outline_rounded,
                title: 'Secure by Design',
                subtitle: 'Your keys stay on your device, always.',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.swap_vert_rounded,
                title: 'Multi-Chain',
                subtitle: 'Ethereum, Polygon, Solana & more.',
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.power_settings_new_rounded,
                title: 'WalletConnect Ready',
                subtitle: 'Connect your existing wallets seamlessly.',
              ),
              const Spacer(flex: 2),
              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _startOnboarding(context),
                  child: const Text('Create New Wallet'),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary CTA
              TextButton(
                onPressed: () => _importWallet(context),
                child: const Text('I already have a wallet'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _startOnboarding(BuildContext context) {
    // Navigate to create wallet flow
    GoRouter.of(context).go('/onboarding/create');
  }

  void _importWallet(BuildContext context) {
    // Navigate to import wallet flow
    GoRouter.of(context).go('/onboarding/import');
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceLight.withOpacity(0.6)
            : AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}