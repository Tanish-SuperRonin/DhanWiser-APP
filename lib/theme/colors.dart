import 'package:flutter/material.dart';

/// Midnight Ledger's stable design tokens.
class DhanWiserColors extends ThemeExtension<DhanWiserColors> {
  final Color background;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color card;
  final Color primary;
  final Color onPrimary;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color outline;
  final Color outlineVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;
  final Color warning;
  final Color coral;
  final Color teal;
  final Color mint;
  final Color success;
  final Color coralTint;
  final Color tealTint;
  final Color primaryTint;
  final Color catFood;
  final Color catTransport;
  final Color catRent;
  final Color catGroceries;
  final Color catUtilities;
  final Color catFun;

  const DhanWiserColors({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.card,
    required this.primary,
    required this.onPrimary,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.outline,
    required this.outlineVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.warning,
    required this.coral,
    required this.teal,
    required this.mint,
    required this.success,
    required this.coralTint,
    required this.tealTint,
    required this.primaryTint,
    required this.catFood,
    required this.catTransport,
    required this.catRent,
    required this.catGroceries,
    required this.catUtilities,
    required this.catFun,
  });

  List<Color> get groupColors => [
        primaryFixed,
        secondary,
        tertiary,
        catFood,
        catTransport,
        catRent,
        catGroceries,
        catUtilities,
        catFun,
      ];

  static DhanWiserColors of(BuildContext context) {
    return Theme.of(context).extension<DhanWiserColors>()!;
  }

  static final DhanWiserColors dark = DhanWiserColors(
    background: const Color(0xFF0B0D10),
    surface: const Color(0xFF111419),
    surfaceDim: const Color(0xFF090B0E),
    surfaceBright: const Color(0xFF2A303A),
    surfaceContainerLowest: const Color(0xFF0E1014),
    surfaceContainerLow: const Color(0xFF15181E),
    surfaceContainer: const Color(0xFF191D24),
    surfaceContainerHigh: const Color(0xFF20252D),
    surfaceContainerHighest: const Color(0xFF292F39),
    surfaceVariant: const Color(0xFF262C35),
    card: const Color(0xFF191D24),
    primary: const Color(0xFFC9F542),
    onPrimary: const Color(0xFF172000),
    primaryFixed: const Color(0xFFC9F542),
    primaryFixedDim: const Color(0xFFA9D72E),
    onPrimaryFixed: const Color(0xFF172000),
    onPrimaryFixedVariant: const Color(0xFF344800),
    primaryContainer: const Color(0xFFB7E83B),
    onPrimaryContainer: const Color(0xFF172000),
    secondary: const Color(0xFFB7ABFF),
    onSecondary: const Color(0xFF21185E),
    secondaryFixed: const Color(0xFFDCD7FF),
    secondaryFixedDim: const Color(0xFFB7ABFF),
    onSecondaryFixed: const Color(0xFF21185E),
    onSecondaryFixedVariant: const Color(0xFF504995),
    secondaryContainer: const Color(0xFF3A356E),
    onSecondaryContainer: const Color(0xFFDCD7FF),
    tertiary: const Color(0xFF66FEA2),
    onTertiary: const Color(0xFF00391C),
    tertiaryFixed: const Color(0xFF66FEA2),
    tertiaryFixedDim: const Color(0xFF43E188),
    onTertiaryFixed: const Color(0xFF00391C),
    onTertiaryFixedVariant: const Color(0xFF00522B),
    tertiaryContainer: const Color(0xFF66FEA2),
    onTertiaryContainer: const Color(0xFF00743F),
    error: const Color(0xFFFF817A),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    textPrimary: const Color(0xFFF5F7FA),
    textSecondary: const Color(0xFFA5ACB9),
    textDisabled: const Color(0xFF707887),
    outline: const Color(0xFF677081),
    outlineVariant: const Color(0xFF2D3440),
    onSurface: const Color(0xFFF5F7FA),
    onSurfaceVariant: const Color(0xFFA5ACB9),
    inverseSurface: const Color(0xFFF5F7FA),
    inverseOnSurface: const Color(0xFF191D24),
    inversePrimary: const Color(0xFF415900),
    positive: const Color(0xFFC9F542),
    positiveSoft: const Color(0x26C9F542),
    negative: const Color(0xFFFF817A),
    negativeSoft: const Color(0x26FF817A),
    warning: const Color(0xFFF2A93B),
    coral: const Color(0xFFFF817A),
    teal: const Color(0xFF66FEA2),
    mint: const Color(0xFF66FEA2),
    success: const Color(0xFF66FEA2),
    coralTint: const Color(0x1AFF817A),
    tealTint: const Color(0x1A66FEA2),
    primaryTint: const Color(0x1AC9F542),
    catFood: const Color(0xFFC9F542),
    catTransport: const Color(0xFFB7ABFF),
    catRent: const Color(0xFF66FEA2),
    catGroceries: const Color(0xFF10B981),
    catUtilities: const Color(0xFFF97316),
    catFun: const Color(0xFFEC4899),
  );

  static final DhanWiserColors light = DhanWiserColors(
    background: const Color(0xFFF8F9F7),
    surface: Colors.white,
    surfaceDim: const Color(0xFFF0F2EE),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF4F6F2),
    surfaceContainer: Colors.white,
    surfaceContainerHigh: const Color(0xFFF2F4F1),
    surfaceContainerHighest: const Color(0xFFE9EDE8),
    surfaceVariant: const Color(0xFFE6EAE5),
    card: Colors.white,
    primary: const Color(0xFF587900),
    onPrimary: Colors.white,
    primaryFixed: const Color(0xFF587900),
    primaryFixedDim: const Color(0xFF6B9000),
    onPrimaryFixed: Colors.white,
    onPrimaryFixedVariant: const Color(0xFF253600),
    primaryContainer: const Color(0xFFE5F4B8),
    onPrimaryContainer: const Color(0xFF253600),
    secondary: const Color(0xFF5C57A9),
    onSecondary: Colors.white,
    secondaryFixed: const Color(0xFFE1DEFF),
    secondaryFixedDim: const Color(0xFF5C57A9),
    onSecondaryFixed: Colors.white,
    onSecondaryFixedVariant: const Color(0xFF29235E),
    secondaryContainer: const Color(0xFFE9E7FF),
    onSecondaryContainer: const Color(0xFF29235E),
    tertiary: const Color(0xFF087552),
    onTertiary: Colors.white,
    tertiaryFixed: const Color(0xFF087552),
    tertiaryFixedDim: const Color(0xFF087552),
    onTertiaryFixed: Colors.white,
    onTertiaryFixedVariant: const Color(0xFF003920),
    tertiaryContainer: const Color(0xFFC1F8D8),
    onTertiaryContainer: const Color(0xFF003920),
    error: const Color(0xFFC43F38),
    onError: Colors.white,
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF5F1713),
    textPrimary: const Color(0xFF171B20),
    textSecondary: const Color(0xFF596270),
    textDisabled: const Color(0xFF88919C),
    outline: const Color(0xFF737D89),
    outlineVariant: const Color(0xFFDCE1DD),
    onSurface: const Color(0xFF171B20),
    onSurfaceVariant: const Color(0xFF596270),
    inverseSurface: const Color(0xFF1A1E24),
    inverseOnSurface: const Color(0xFFF8F9F7),
    inversePrimary: const Color(0xFF587900),
    positive: const Color(0xFF587900),
    positiveSoft: const Color(0xFF587900).withValues(alpha: 0.14),
    negative: const Color(0xFFC43F38),
    negativeSoft: const Color(0xFFC43F38).withValues(alpha: 0.14),
    warning: const Color(0xFFF2A93B),
    coral: const Color(0xFFC43F38),
    teal: const Color(0xFF087552),
    mint: const Color(0xFF087552),
    success: const Color(0xFF087552),
    coralTint: const Color(0xFFC43F38).withValues(alpha: 0.10),
    tealTint: const Color(0xFF087552).withValues(alpha: 0.10),
    primaryTint: const Color(0xFF587900).withValues(alpha: 0.10),
    catFood: const Color(0xFF587900),
    catTransport: const Color(0xFF5C57A9),
    catRent: const Color(0xFF087552),
    catGroceries: const Color(0xFF10B981),
    catUtilities: const Color(0xFFF97316),
    catFun: const Color(0xFFEC4899),
  );

  @override
  ThemeExtension<DhanWiserColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceVariant,
    Color? card,
    Color? primary,
    Color? onPrimary,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? onPrimaryFixed,
    Color? onPrimaryFixedVariant,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryFixed,
    Color? onTertiaryFixedVariant,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? outline,
    Color? outlineVariant,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? inverseOnSurface,
    Color? inversePrimary,
    Color? positive,
    Color? positiveSoft,
    Color? negative,
    Color? negativeSoft,
    Color? warning,
    Color? coral,
    Color? teal,
    Color? mint,
    Color? success,
    Color? coralTint,
    Color? tealTint,
    Color? primaryTint,
    Color? catFood,
    Color? catTransport,
    Color? catRent,
    Color? catGroceries,
    Color? catUtilities,
    Color? catFun,
  }) {
    return DhanWiserColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseOnSurface: inverseOnSurface ?? this.inverseOnSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      positive: positive ?? this.positive,
      positiveSoft: positiveSoft ?? this.positiveSoft,
      negative: negative ?? this.negative,
      negativeSoft: negativeSoft ?? this.negativeSoft,
      warning: warning ?? this.warning,
      coral: coral ?? this.coral,
      teal: teal ?? this.teal,
      mint: mint ?? this.mint,
      success: success ?? this.success,
      coralTint: coralTint ?? this.coralTint,
      tealTint: tealTint ?? this.tealTint,
      primaryTint: primaryTint ?? this.primaryTint,
      catFood: catFood ?? this.catFood,
      catTransport: catTransport ?? this.catTransport,
      catRent: catRent ?? this.catRent,
      catGroceries: catGroceries ?? this.catGroceries,
      catUtilities: catUtilities ?? this.catUtilities,
      catFun: catFun ?? this.catFun,
    );
  }

  @override
  ThemeExtension<DhanWiserColors> lerp(
      covariant ThemeExtension<DhanWiserColors>? other, double t) {
    if (other is! DhanWiserColors) return this;
    return DhanWiserColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t)!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      surfaceContainerLowest: Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerLow: Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh: Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant: Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim: Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      onSecondaryFixed: Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      secondaryContainer: Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer: Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim: Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant: Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      tertiaryContainer: Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiaryContainer: Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface: Color.lerp(inverseOnSurface, other.inverseOnSurface, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSoft: Color.lerp(positiveSoft, other.positiveSoft, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeSoft: Color.lerp(negativeSoft, other.negativeSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      success: Color.lerp(success, other.success, t)!,
      coralTint: Color.lerp(coralTint, other.coralTint, t)!,
      tealTint: Color.lerp(tealTint, other.tealTint, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      catFood: Color.lerp(catFood, other.catFood, t)!,
      catTransport: Color.lerp(catTransport, other.catTransport, t)!,
      catRent: Color.lerp(catRent, other.catRent, t)!,
      catGroceries: Color.lerp(catGroceries, other.catGroceries, t)!,
      catUtilities: Color.lerp(catUtilities, other.catUtilities, t)!,
      catFun: Color.lerp(catFun, other.catFun, t)!,
    );
  }
}
