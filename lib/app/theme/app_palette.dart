import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colors that follow the active [ThemeData] brightness.
class AppPalette {
  const AppPalette._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.offlineBannerBackground,
    required this.offlineBannerForeground,
  });

  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color offlineBannerBackground;
  final Color offlineBannerForeground;

  static AppPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AppPalette._(
        isDark: true,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceMuted: AppColors.surfaceLight,
        border: AppColors.border,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textTertiary: AppColors.textTertiary,
        offlineBannerBackground: Color(0xFF9A3412),
        offlineBannerForeground: Colors.white,
      );
    }
    return const AppPalette._(
      isDark: false,
      background: Color(0xFFF7F7FB),
      surface: Colors.white,
      surfaceMuted: Color(0xFFF0F1F7),
      border: Color(0xFFD5D7E6),
      textPrimary: Color(0xFF111127),
      textSecondary: Color(0xFF4A4A66),
      textTertiary: Color(0xFF6A6A85),
      offlineBannerBackground: Color(0xFFFFEDD5),
      offlineBannerForeground: Color(0xFF7C2D12),
    );
  }
}

extension AppLayout on BuildContext {
  double get screenPadding {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= 600) return 32;
    if (width >= 400) return 24;
    return 20;
  }
}
