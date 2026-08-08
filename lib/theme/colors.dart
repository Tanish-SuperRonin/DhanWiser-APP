import 'package:flutter/material.dart';

/// Midnight Ledger's stable design tokens. New widgets should use ThemeData
/// where possible so they automatically respond to bright mode.
class DhanWiserColors {
  DhanWiserColors._();
  static Color background = Color(0xFF0B0D10);
  static Color surface = Color(0xFF111419);
  static Color surfaceDim = Color(0xFF090B0E);
  static Color surfaceBright = Color(0xFF2A303A);
  static Color surfaceContainerLowest = Color(0xFF0E1014);
  static Color surfaceContainerLow = Color(0xFF15181E);
  static Color surfaceContainer = Color(0xFF191D24);
  static Color surfaceContainerHigh = Color(0xFF20252D);
  static Color surfaceContainerHighest = Color(0xFF292F39);
  static Color surfaceVariant = Color(0xFF262C35);
  static Color card = surfaceContainer;
  static Color primary = Color(0xFFC9F542);
  static Color onPrimary = Color(0xFF172000);
  static Color primaryFixed = Color(0xFFC9F542);
  static Color primaryFixedDim = Color(0xFFA9D72E);
  static Color onPrimaryFixed = Color(0xFF172000);
  static Color onPrimaryFixedVariant = Color(0xFF344800);
  static Color primaryContainer = Color(0xFFB7E83B);
  static Color onPrimaryContainer = Color(0xFF172000);
  static Color secondary = Color(0xFFB7ABFF);
  static Color onSecondary = Color(0xFF21185E);
  static Color secondaryFixed = Color(0xFFDCD7FF);
  static Color secondaryFixedDim = secondary;
  static Color onSecondaryFixed = onSecondary;
  static Color onSecondaryFixedVariant = Color(0xFF504995);
  static Color secondaryContainer = Color(0xFF3A356E);
  static Color onSecondaryContainer = Color(0xFFDCD7FF);
  static Color tertiary = Color(0xFF66FEA2);
  static Color onTertiary = Color(0xFF00391C);
  static Color tertiaryFixed = tertiary;
  static Color tertiaryFixedDim = Color(0xFF43E188);
  static Color onTertiaryFixed = onTertiary;
  static Color onTertiaryFixedVariant = Color(0xFF00522B);
  static Color tertiaryContainer = tertiary;
  static Color onTertiaryContainer = Color(0xFF00743F);
  static Color error = Color(0xFFFF817A);
  static Color onError = Color(0xFF690005);
  static Color errorContainer = Color(0xFF93000A);
  static Color onErrorContainer = Color(0xFFFFDAD6);
  static Color textPrimary = Color(0xFFF5F7FA);
  static Color textSecondary = Color(0xFFA5ACB9);
  static Color textDisabled = Color(0xFF707887);
  static Color outline = Color(0xFF677081);
  static Color outlineVariant = Color(0xFF2D3440);
  static Color onSurface = textPrimary;
  static Color onSurfaceVariant = textSecondary;
  static Color inverseSurface = Color(0xFFF5F7FA);
  static Color inverseOnSurface = Color(0xFF191D24);
  static Color inversePrimary = Color(0xFF415900);
  static Color positive = primaryFixed;
  static Color positiveSoft = Color(0x26C9F542);
  static Color negative = error;
  static Color negativeSoft = Color(0x26FF817A);
  static Color warning = Color(0xFFF2A93B);
  static Color coral = error;
  static Color teal = tertiary;
  static Color mint = tertiary;
  static Color success = tertiary;
  static Color coralTint = Color(0x1AFF817A);
  static Color tealTint = Color(0x1A66FEA2);
  static Color primaryTint = Color(0x1AC9F542);
  static Color catFood = primaryFixed;
  static Color catTransport = secondary;
  static Color catRent = tertiary;
  static Color catGroceries = Color(0xFF10B981);
  static Color catUtilities = Color(0xFFF97316);
  static Color catFun = Color(0xFFEC4899);
  static List<Color> groupColors = [
    primaryFixed,
    secondary,
    tertiary,
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF10B981)
  ];
  static void setBrightness(Brightness brightness) {
    final light = brightness == Brightness.light;
    background = light ? const Color(0xFFF8F9F7) : const Color(0xFF0B0D10);
    surface = light ? Colors.white : const Color(0xFF111419);
    surfaceDim = light ? const Color(0xFFF0F2EE) : const Color(0xFF090B0E);
    surfaceBright = light ? Colors.white : const Color(0xFF2A303A);
    surfaceContainerLowest = light ? Colors.white : const Color(0xFF0E1014);
    surfaceContainerLow = light ? const Color(0xFFF4F6F2) : const Color(0xFF15181E);
    surfaceContainer = light ? Colors.white : const Color(0xFF191D24);
    surfaceContainerHigh = light ? const Color(0xFFF2F4F1) : const Color(0xFF20252D);
    surfaceContainerHighest = light ? const Color(0xFFE9EDE8) : const Color(0xFF292F39);
    surfaceVariant = light ? const Color(0xFFE6EAE5) : const Color(0xFF262C35);
    card = surfaceContainer;
    primary = primaryFixed = light ? const Color(0xFF587900) : const Color(0xFFC9F542);
    primaryContainer = light ? const Color(0xFFE5F4B8) : const Color(0xFFB7E83B);
    onPrimary = onPrimaryFixed = light ? Colors.white : const Color(0xFF172000);
    onPrimaryContainer = light ? const Color(0xFF253600) : const Color(0xFF172000);
    secondary = light ? const Color(0xFF5C57A9) : const Color(0xFFB7ABFF);
    tertiary = light ? const Color(0xFF087552) : const Color(0xFF66FEA2);
    error = light ? const Color(0xFFC43F38) : const Color(0xFFFF817A);
    textPrimary = light ? const Color(0xFF171B20) : const Color(0xFFF5F7FA);
    textSecondary = light ? const Color(0xFF596270) : const Color(0xFFA5ACB9);
    textDisabled = light ? const Color(0xFF88919C) : const Color(0xFF707887);
    outline = light ? const Color(0xFF737D89) : const Color(0xFF677081);
    outlineVariant = light ? const Color(0xFFDCE1DD) : const Color(0xFF2D3440);
    onSurface = textPrimary; onSurfaceVariant = textSecondary;
  }

}
