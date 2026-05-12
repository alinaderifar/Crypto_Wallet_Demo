import 'package:crypto_wallet_demo/app/theme/app_palette.dart';
import 'package:crypto_wallet_demo/core/network/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Thin bar when [ConnectivityCubit] reports offline (after first check).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      buildWhen: (a, b) =>
          a.shouldShowOfflineBanner != b.shouldShowOfflineBanner ||
          a.hasChecked != b.hasChecked,
      builder: (context, state) {
        if (!state.shouldShowOfflineBanner) {
          return const SizedBox.shrink();
        }
        return Material(
          color: palette.offlineBannerBackground,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off,
                    color: palette.offlineBannerForeground,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No internet connection. Some actions are unavailable.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.offlineBannerForeground,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
