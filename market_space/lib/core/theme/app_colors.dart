import 'package:flutter/material.dart';

/// Centralized Monochrome Design System Color Tokens.
/// Exclusively Black, White, and Grayscale shades.
/// No extra accent colors (blue, green, purple, orange, etc.) are allowed in the core identity.
class AppColors {
  // --- Light Theme Tokens ---
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF5F5F5);
  static const Color surfaceTertiary = Color(0xFFEEEEEE);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF404040);
  static const Color textMuted = Color(0xFF666666);
  static const Color border = Color(0xFFE0E0E0);
  static const Color iconPrimary = Color(0xFF111111);
  static const Color iconSecondary = Color(0xFF555555);
  static const Color primary = Color(0xFF111111);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color disabled = Color(0xFFBDBDBD);

  // --- Dark Theme Tokens ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color darkSurfaceSecondary = Color(0xFF262626);
  static const Color darkSurfaceTertiary = Color(0xFF303030);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFD0D0D0);
  static const Color darkTextMuted = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF383838);
  static const Color darkIconPrimary = Color(0xFFFFFFFF);
  static const Color darkIconSecondary = Color(0xFFC0C0C0);
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF111111);

  // --- Legacy Compatibility Tokens (Mapped Strictly to Monochrome) ---
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightBorder = border;
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightTextMuted = textMuted;

  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryTint = Color(0xFFF5F5F5);

  static const Color secondary = Color(0xFF262626);
  static const Color secondaryDark = Color(0xFF111111);
  static const Color secondaryLight = Color(0xFF555555);
  static const Color secondaryTint = Color(0xFFF5F5F5);

  static const Color tertiary = Color(0xFF404040);
  static const Color tertiaryDark = Color(0xFF111111);
  static const Color tertiaryLight = Color(0xFF757575);
  static const Color tertiaryTint = Color(0xFFF5F5F5);

  static const Color neutral = Color(0xFF111111);
  static const Color neutralLight = Color(0xFF262626);

  // Status tokens in Monochrome system: rely on high-contrast dark tones and text/icons
  static const Color success = Color(0xFF111111);
  static const Color warning = Color(0xFF404040);
  static const Color error = Color(0xFF111111);
  static const Color errorTint = Color(0xFFF5F5F5);
  static const Color info = Color(0xFF262626);
  static const Color infoTint = Color(0xFFF5F5F5);

  // Grayscale Palette tokens
  static const Color slate50 = Color(0xFFFAFAFA);
  static const Color slate100 = Color(0xFFF5F5F5);
  static const Color slate200 = Color(0xFFEEEEEE);
  static const Color slate300 = Color(0xFFE0E0E0);
  static const Color slate400 = Color(0xFFBDBDBD);
  static const Color slate500 = Color(0xFF757575);
  static const Color slate600 = Color(0xFF616161);
  static const Color slate700 = Color(0xFF424242);
  static const Color slate800 = Color(0xFF212121);
  static const Color slate900 = Color(0xFF111111);

  // Emerald tokens mapped to elegant high-contrast monochrome
  static const Color emerald50 = Color(0xFFFAFAFA);
  static const Color emerald100 = Color(0xFFF0F0F0);
  static const Color emerald200 = Color(0xFFE0E0E0);
  static const Color emerald300 = Color(0xFFBDBDBD);
  static const Color emerald600 = Color(0xFF424242);
  static const Color emerald700 = Color(0xFF212121);
  static const Color emerald800 = Color(0xFF111111);

  static const Color rose600 = Color(0xFF111111);
  static const Color accent = Color(0xFF111111);
  static const Color accentDark = Color(0xFF000000);
}
