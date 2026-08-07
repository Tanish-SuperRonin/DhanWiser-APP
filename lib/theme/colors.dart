import 'package:flutter/material.dart';

/// DhanWiser Design System Colors — v2
///
/// Warm amber accent (#F5A623) on deep obsidian background (#0F0E0D).
/// Matches the new Dhanwiser-New frontend design tokens.
/// Dark mode only. Premium financial app aesthetic.
class DhanWiserColors {
  DhanWiserColors._();

  // ──────────────────────────────────────────────
  // Primary — Warm Amber (brand identity)
  // ──────────────────────────────────────────────
  static const Color primary = Color(0xFFF5A623);
  static const Color onPrimary = Color(0xFF0F0E0D);
  static const Color primaryContainer = Color(0xFFF5A623);
  static const Color onPrimaryContainer = Color(0xFF0F0E0D);

  // Primary variants
  static const Color accentSoft = Color(0x1FF5A623);     // 12% opacity
  static const Color accentGlow = Color(0x40F5A623);     // 25% opacity
  static const Color accentDark = Color(0xFFC4831A);

  // ──────────────────────────────────────────────
  // Secondary — kept for gradient effects
  // ──────────────────────────────────────────────
  static const Color secondary = Color(0xFF7B61FF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF4720CA);
  static const Color onSecondaryContainer = Color(0xFFBAAEFF);

  // ──────────────────────────────────────────────
  // Tertiary
  // ──────────────────────────────────────────────
  static const Color tertiary = Color(0xFFB5C9D9);
  static const Color onTertiary = Color(0xFF1F333F);
  static const Color tertiaryContainer = Color(0xFFD0E5F5);
  static const Color onTertiaryContainer = Color(0xFF536774);

  // ──────────────────────────────────────────────
  // Semantic / Financial Colors
  // ──────────────────────────────────────────────
  static const Color error = Color(0xFFF87171);
  static const Color onError = Color(0xFF0F0E0D);
  static const Color errorContainer = Color(0x26F87171);   // 15% negative-soft
  static const Color onErrorContainer = Color(0xFFF87171);

  static const Color positive = Color(0xFF34D399);         // Owed to you / success
  static const Color positiveSoft = Color(0x2634D399);     // 15%
  static const Color negative = Color(0xFFF87171);         // You owe / error
  static const Color negativeSoft = Color(0x26F87171);     // 15%
  static const Color warning = Color(0xFFFBBF24);

  // Financial indicator aliases (backward compat)
  static const Color coral = Color(0xFFF87171);
  static const Color teal = Color(0xFF34D399);
  static const Color mint = Color(0xFF34D399);
  static const Color success = Color(0xFF34D399);

  // Tints for subtle backgrounds
  static const Color coralTint = Color(0x1AF87171);
  static const Color tealTint = Color(0x1A34D399);
  static const Color primaryTint = Color(0x1AF5A623);

  // ──────────────────────────────────────────────
  // Surfaces — Premium Dark (warm obsidian tones)
  // ──────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0E0D);   // bg-base
  static const Color surfaceDark = Color(0xFF0F0E0D);      // bg-base
  static const Color surfaceVariantDark = Color(0xFF2E2B28);

  // M3 surface container hierarchy (warm tones)
  static const Color surfaceContainerLowestDark = Color(0xFF0A0908);
  static const Color surfaceContainerLowDark = Color(0xFF141311);
  static const Color surfaceContainerDark = Color(0xFF1A1917);           // bg-surface (cards)
  static const Color surfaceContainerHighDark = Color(0xFF242220);       // bg-elevated
  static const Color surfaceContainerHighestDark = Color(0xFF2E2B28);   // bg-overlay

  // Elevated surface aliases
  static const Color surfaceElevatedDark = Color(0xFF1A1917);

  // Light mode fallbacks (maps to dark — dark-only app)
  static const Color backgroundLight = Color(0xFF0F0E0D);
  static const Color surfaceLight = Color(0xFF0F0E0D);
  static const Color surfaceVariantLight = Color(0xFF2E2B28);
  static const Color surfaceContainerLowestLight = Color(0xFF0A0908);
  static const Color surfaceContainerLowLight = Color(0xFF141311);
  static const Color surfaceContainerLight = Color(0xFF1A1917);
  static const Color surfaceContainerHighLight = Color(0xFF242220);
  static const Color surfaceContainerHighestLight = Color(0xFF2E2B28);
  static const Color surfaceElevatedLight = Color(0xFF1A1917);

  // ──────────────────────────────────────────────
  // Input Fields
  // ──────────────────────────────────────────────
  static const Color inputDark = Color(0xFF1A1917);
  static const Color inputLight = Color(0xFF1A1917);

  // ──────────────────────────────────────────────
  // Text — warm-tinted neutrals
  // ──────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF5F2EE);
  static const Color textSecondaryDark = Color(0xFF9E9992);
  static const Color textMuted = Color(0xFF5C5752);
  static const Color textOnAccent = Color(0xFF0F0E0D);
  static const Color textPrimaryLight = Color(0xFFF5F2EE);
  static const Color textSecondaryLight = Color(0xFF9E9992);

  // ──────────────────────────────────────────────
  // Outline / Dividers (warm tones)
  // ──────────────────────────────────────────────
  static const Color outlineDark = Color(0xFF2E2B28);       // border-main
  static const Color outlineVariantDark = Color(0xFF1F1D1B); // border-subtle
  static const Color outlineLight = Color(0xFF2E2B28);
  static const Color outlineVariantLight = Color(0xFF1F1D1B);

  // ──────────────────────────────────────────────
  // Hero Gradient
  // ──────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5A623), Color(0xFFC4831A)],
  );

  // ──────────────────────────────────────────────
  // Glow shadows
  // ──────────────────────────────────────────────
  static const Color limeGlow = Color(0x40F5A623);
  static const Color violetGlow = Color(0x4D7B61FF);

  // ──────────────────────────────────────────────
  // Neutrals (backward compat)
  // ──────────────────────────────────────────────
  static const Color gray50 = Color(0xFFF5F2EE);
  static const Color gray100 = Color(0xFF9E9992);
  static const Color gray200 = Color(0xFF5C5752);
  static const Color gray300 = Color(0xFF2E2B28);
  static const Color gray400 = Color(0xFF242220);
  static const Color gray500 = Color(0xFF1A1917);
  static const Color gray600 = Color(0xFF141311);
  static const Color gray700 = Color(0xFF0F0E0D);
  static const Color gray800 = Color(0xFF0A0908);
  static const Color gray900 = Color(0xFF050504);

  // Backward compat aliases
  static const Color primaryLight = Color(0xFFF5A623);
  static const Color primaryDark = Color(0xFFC4831A);

  // ──────────────────────────────────────────────
  // Category Colors (for expenses)
  // ──────────────────────────────────────────────
  static const Color catFood = Color(0xFFF5A623);
  static const Color catTransport = Color(0xFF3B82F6);
  static const Color catRent = Color(0xFF8B5CF6);
  static const Color catGroceries = Color(0xFF10B981);
  static const Color catUtilities = Color(0xFFF97316);
  static const Color catFun = Color(0xFFEC4899);

  // Group avatar colors
  static const List<Color> groupColors = [
    Color(0xFFF5A623),
    Color(0xFF0D9488),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF10B981),
  ];

  // ──────────────────────────────────────────────
  // Shadows
  // ──────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floatShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 40,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}