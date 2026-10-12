import 'package:flutter/material.dart';

/// Design tokens for colors aligned with Stitch "Vibrant Marketplace" specification.
/// Primary: #FF4B26, Secondary: #10B981, Tertiary: #F59E0B, Neutral: #0F172A
class AppColors {
  // Brand colors confirmed from Stitch color.png
  static const Color primary = Color(0xFFFF4B26);
  static const Color primaryDark = Color(0xFFC2410C);
  static const Color primaryLight = Color(0xFFFF7A59);
  static const Color primaryTint = Color(0xFFFFF1EE);

  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF047857);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryTint = Color(0xFFECFDF5);

  static const Color tertiary = Color(0xFFF59E0B);
  static const Color tertiaryDark = Color(0xFFB45309);
  static const Color tertiaryLight = Color(0xFFFBBF24);
  static const Color tertiaryTint = Color(0xFFFFFBEB);

  static const Color neutral = Color(0xFF0F172A);
  static const Color neutralLight = Color(0xFF1E293B);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorTint = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoTint = Color(0xFFEFF6FF);

  // Light theme tokens
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark theme tokens
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
}
