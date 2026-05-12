import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/onboarding/welcome_page.dart';
import '../../features/auth/presentation/pages/onboarding/create_wallet_page.dart';
import '../../features/auth/presentation/pages/onboarding/backup_seed_page.dart';
import '../../features/auth/presentation/pages/onboarding/import_wallet_page.dart';
import '../../features/auth/presentation/pages/onboarding/verify_pin_page.dart';
import '../../features/wallet/presentation/pages/home/home_page.dart';
import '../../features/wallet/presentation/pages/wallet/wallet_page.dart';
import '../../features/wallet/presentation/pages/send/send_page.dart';
import '../../features/wallet/presentation/pages/receive/receive_page.dart';
import '../../features/wallet/presentation/pages/transaction_detail/transaction_detail_page.dart';
import '../../features/wallet/presentation/pages/chain_select/chain_select_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

import '../../injection/service_locator.dart';

/// Root navigation router for the Crypto Wallet application.
///
/// Defines the route hierarchy:
/// - /onboarding → welcome, create, backup, import, verify
/// - /home → wallet dashboard, send, receive, chains, settings
final appRouter = GoRouter(
  initialLocation: '/onboarding',
  debugLogDiagnostics: false,
  refreshListenable: walletSessionNotifier,
  redirect: (context, state) {
    final loggedIn = walletSessionNotifier.value;
    final loc = state.matchedLocation;
    final onOnboarding = loc.startsWith('/onboarding');

    if (!loggedIn && !onOnboarding) return '/onboarding';
    if (loggedIn && onOnboarding) return '/home';
    return null;
  },
  routes: [
    // ── Onboarding Flow ──────────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WelcomePage(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      routes: [
        GoRoute(
          path: 'create',
          name: 'create-wallet',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CreateWalletPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: 'backup',
          name: 'backup-seed',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BackupSeedPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: 'verify',
          name: 'verify-pin',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const VerifyPinPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: 'import',
          name: 'import-wallet',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ImportWalletPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),
      ],
    ),

    // ── Main App Shell ───────────────────────────────────────────
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomePage(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      routes: [
        // Wallet detail
        GoRoute(
          path: 'wallet',
          name: 'wallet',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const WalletPage(),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        // Send
        GoRoute(
          path: 'send',
          name: 'send',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SendPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),

        // Receive
        GoRoute(
          path: 'receive',
          name: 'receive',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ReceivePage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),

        // Chain Select
        GoRoute(
          path: 'chains',
          name: 'chain-select',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChainSelectPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),

        // Transaction Detail
        GoRoute(
          path: 'transaction/:txHash',
          name: 'transaction-detail',
          pageBuilder: (context, state) {
            final txHash = state.pathParameters['txHash'] ?? '';
            return CustomTransitionPage(
              key: state.pageKey,
              child: TransactionDetailPage(txHash: txHash),
              transitionsBuilder: (context, animation, _, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),

        // Settings
        GoRoute(
          path: 'settings',
          name: 'settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsPage(),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              state.error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
