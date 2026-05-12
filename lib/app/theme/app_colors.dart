import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF4A42CC);

  // Accent
  static const Color accent = Color(0xFF00D4AA);
  static const Color accentLight = Color(0xFF33D9B2);

  // Background
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF252542);
  static const Color surfaceVariant = Color(0xFF2D2D4A);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textTertiary = Color(0xFF7A7A96);

  // Status
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D6A);
  static const Color info = Color(0xFF6C63FF);

  // Borders & dividers
  static const Color border = Color(0xFF2D2D4A);
  static const Color divider = Color(0xFF1F1F3A);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primaryLight],
  );

  // Private constructor
  AppColors._();
}
