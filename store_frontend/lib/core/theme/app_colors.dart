import 'package:flutter/material.dart';

/// Premium color palette for the e-commerce application.
///
/// Inspired by Shopify Plus, Apple, and Zara aesthetics.
/// Clean, minimalist, and trustworthy color scheme.
class AppColors {
  AppColors._();

  // ─── PRIMARY BRAND COLORS ──────────────────────────────────────────
  /// Deep indigo - Primary brand color for CTAs, links, and highlights
  static const Color primary = Color(0xFF1A1A2E);

  /// Lighter shade for hover states
  static const Color primaryLight = Color(0xFF2D2D44);

  /// Darker shade for pressed states
  static const Color primaryDark = Color(0xFF0F0F1A);

  // ─── ACCENT COLORS ─────────────────────────────────────────────────
  /// Elegant gold accent for premium elements
  static const Color accent = Color(0xFFD4A574);

  /// Soft coral for sale tags and promotions
  static const Color coral = Color(0xFFE07A5F);

  /// Success green
  static const Color success = Color(0xFF2E7D32);

  /// Warning amber
  static const Color warning = Color(0xFFF9A825);

  /// Error red
  static const Color error = Color(0xFFD32F2F);

  // ─── NEUTRAL COLORS ────────────────────────────────────────────────
  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Off-white background - Premium feel
  static const Color background = Color(0xFFFAFAFA);

  /// Card/Surface color
  static const Color surface = Color(0xFFFFFFFF);

  /// Light grey for dividers
  static const Color divider = Color(0xFFE8E8E8);

  /// Border color
  static const Color border = Color(0xFFE0E0E0);

  /// Disabled elements
  static const Color disabled = Color(0xFFBDBDBD);

  // ─── TEXT COLORS ───────────────────────────────────────────────────
  /// Primary text - Dark crisp typography
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text - Muted descriptions
  static const Color textSecondary = Color(0xFF666666);

  /// Tertiary text - Hints and labels
  static const Color textTertiary = Color(0xFF999999);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── SHIMMER COLORS ────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ─── GRADIENT ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFE8B896)],
  );

  // ─── SHADOW ────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get hoverShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
