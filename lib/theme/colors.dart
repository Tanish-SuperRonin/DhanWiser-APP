import 'package:flutter/material.dart';

/// DhanWiser Design System Colors — v3 (Lime & Violet)
///
/// Lime Green (#C0F500) and Violet (#C9BFFF) on a deep black background (#131315).
/// Matches the new HTML/Tailwind frontend design tokens.
class DhanWiserColors {
  DhanWiserColors._();

  // ──────────────────────────────────────────────
  // Base Palette (from Tailwind Config)
  // ──────────────────────────────────────────────
  static const Color background = Color(0xFF131315);
  static const Color surface = Color(0xFF161618);
  static const Color surfaceDim = Color(0xFF131315);
  static const Color surfaceBright = Color(0xFF39393B);

  // Surface Containers
  static const Color surfaceContainerLowest = Color(0xFF0E0E10);
  static const Color surfaceContainerLow = Color(0xFF1C1B1D);
  static const Color surfaceContainer = Color(0xFF201F21);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2C);
  static const Color surfaceContainerHighest = Color(0xFF353437);
  static const Color card = Color(0xFF1E1E22);

  // Primary (White in this config)
  static const Color primary = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF273500);
  
  // Primary Fixed (Lime Green - main brand color)
  static const Color primaryFixed = Color(0xFFC0F500);
  static const Color primaryFixedDim = Color(0xFFA8D700);
  static const Color onPrimaryFixed = Color(0xFF161F00);
  static const Color onPrimaryFixedVariant = Color(0xFF3B4D00);
  static const Color primaryContainer = Color(0xFFC0F500);
  static const Color onPrimaryContainer = Color(0xFF546D00);

  // Secondary (Violet)
  static const Color secondary = Color(0xFFC9BFFF);
  static const Color onSecondary = Color(0xFF2E009C);
  static const Color secondaryFixed = Color(0xFFE5DEFF);
  static const Color secondaryFixedDim = Color(0xFFC9BFFF);
  static const Color onSecondaryFixed = Color(0xFF1A0063);
  static const Color onSecondaryFixedVariant = Color(0xFF441CC8);
  static const Color secondaryContainer = Color(0xFF4720CA);
  static const Color onSecondaryContainer = Color(0xFFBAAEFF);

  // Tertiary (Mint Green)
  static const Color tertiary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFF00391C);
  static const Color tertiaryFixed = Color(0xFF66FEA2);
  static const Color tertiaryFixedDim = Color(0xFF43E188);
  static const Color onTertiaryFixed = Color(0xFF00210E);
  static const Color onTertiaryFixedVariant = Color(0xFF00522B);
  static const Color tertiaryContainer = Color(0xFF66FEA2);
  static const Color onTertiaryContainer = Color(0xFF00743F);

  // Error / Financial Negatives
  static const Color error = Color(0xFFFF5C5C);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // Text Colors
  static const Color textPrimary = Color(0xFFF7F7F5);
  static const Color textSecondary = Color(0xFF9A9AA2);
  static const Color textDisabled = Color(0xFF5C5C63);

  // Outlines
  static const Color outline = Color(0xFF8E9479);
  static const Color outlineVariant = Color(0xFF434933);

  // Additional Mappings
  static const Color onSurface = Color(0xFFE5E1E4);
  static const Color onSurfaceVariant = Color(0xFFC4CAAC);
  static const Color inverseSurface = Color(0xFFE5E1E4);
  static const Color inverseOnSurface = Color(0xFF313032);
  static const Color inversePrimary = Color(0xFF4F6600);

  // ──────────────────────────────────────────────
  // Financial Indicator Aliases (backward compat)
  // ──────────────────────────────────────────────
  static const Color positive = primaryFixed;
  static const Color positiveSoft = Color(0x26C0F500); 
  static const Color negative = secondary; 
  static const Color negativeSoft = Color(0x26C9BFFF);
  static const Color warning = Color(0xFFFBBF24);
  static const Color coral = error;
  static const Color teal = tertiaryFixed;
  static const Color mint = tertiaryFixed;
  static const Color success = tertiaryFixed;

  // Tints for subtle backgrounds
  static const Color coralTint = Color(0x1AF87171);
  static const Color tealTint = Color(0x1A34D399);
  static const Color primaryTint = Color(0x1AF5A623);

  // ──────────────────────────────────────────────
  // Category Colors (for expenses)
  // ──────────────────────────────────────────────
  static const Color catFood = primaryFixed;
  static const Color catTransport = secondary;
  static const Color catRent = tertiaryFixed;
  static const Color catGroceries = Color(0xFF10B981);
  static const Color catUtilities = Color(0xFFF97316);
  static const Color catFun = Color(0xFFEC4899);

  // Group avatar colors
  static const List<Color> groupColors = [
    primaryFixed,
    secondary,
    tertiaryFixed,
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF10B981),
  ];
}