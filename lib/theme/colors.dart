import 'package:flutter/material.dart';

/// DhanWiser's semantic color tokens for both light and dark themes.
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

  Color get emerald => positive;
  Color get carmine => negative;
  Color get cardBorder => outlineVariant;
  Color get divider => outlineVariant.withValues(alpha: 0.5);

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
    background: const Color(0xFF11120F),
    surface: const Color(0xFF191A17),
    surfaceDim: const Color(0xFF0A0B09),
    surfaceBright: const Color(0xFF292A26),
    surfaceContainerLowest: const Color(0xFF0E0F0C),
    surfaceContainerLow: const Color(0xFF151613),
    surfaceContainer: const Color(0xFF1D1E1A),
    surfaceContainerHigh: const Color(0xFF242520),
    surfaceContainerHighest: const Color(0xFF2E2F29),
    surfaceVariant: const Color(0xFF22231F),
    card: const Color(0xFF1B1C19),
    primary: const Color(0xFFFF7D3B),
    onPrimary: const Color(0xFF2B0E02),
    primaryFixed: const Color(0xFFFF7D3B),
    primaryFixedDim: const Color(0xFFE86420),
    onPrimaryFixed: const Color(0xFF2B0E02),
    onPrimaryFixedVariant: const Color(0xFF5D1D02),
    primaryContainer: const Color(0xFF381B0E),
    onPrimaryContainer: const Color(0xFFFFD8C3),
    secondary: const Color(0xFFD6C2B6),
    onSecondary: const Color(0xFF2F2119),
    secondaryFixed: const Color(0xFFEFE5DE),
    secondaryFixedDim: const Color(0xFFA59388),
    onSecondaryFixed: const Color(0xFF2F2119),
    onSecondaryFixedVariant: const Color(0xFF4B3B31),
    secondaryContainer: const Color(0xFF33241C),
    onSecondaryContainer: const Color(0xFFF2E6E0),
    tertiary: const Color(0xFF79B48D),
    onTertiary: const Color(0xFF17271B),
    tertiaryFixed: const Color(0xFFC8E2CC),
    tertiaryFixedDim: const Color(0xFF79B48D),
    onTertiaryFixed: const Color(0xFF17271B),
    onTertiaryFixedVariant: const Color(0xFF355641),
    tertiaryContainer: const Color(0xFF24372A),
    onTertiaryContainer: const Color(0xFFD8EBDD),
    error: const Color(0xFFE58D86),
    onError: const Color(0xFF351B19),
    errorContainer: const Color(0xFF3D2422),
    onErrorContainer: const Color(0xFFFFDAD6),
    textPrimary: const Color(0xFFF1F0EA),
    textSecondary: const Color(0xFFA6A69E),
    textDisabled: const Color(0xFF6C6D65),
    outline: const Color(0xFF3D3E38),
    outlineVariant: const Color(0xFF2A2B26),
    onSurface: const Color(0xFFF1F0EA),
    onSurfaceVariant: const Color(0xFFA6A69E),
    inverseSurface: const Color(0xFFF1F0EA),
    inverseOnSurface: const Color(0xFF11120F),
    inversePrimary: const Color(0xFFD84F05),
    positive: const Color(0xFF91B59A),
    positiveSoft: const Color(0x1A91B59A),
    negative: const Color(0xFFE58D86),
    negativeSoft: const Color(0x1AE58D86),
    warning: const Color(0xFFD2AC72),
    coral: const Color(0xFFE58D86),
    teal: const Color(0xFF83B9B1),
    mint: const Color(0xFF91B59A),
    success: const Color(0xFF79B48D),
    coralTint: const Color(0x1AE58D86),
    tealTint: const Color(0x1A83B9B1),
    primaryTint: const Color(0x22FF7D3B),
    catFood: const Color(0xFFC28A60),
    catTransport: const Color(0xFF789BAA),
    catRent: const Color(0xFFC48666),
    catGroceries: const Color(0xFF83A68A),
    catUtilities: const Color(0xFFB9A16D),
    catFun: const Color(0xFFB47D98),
  );

  static final DhanWiserColors light = DhanWiserColors(
    background: const Color(0xFFF5F4F0),
    surface: Colors.white,
    surfaceDim: const Color(0xFFECEBE6),
    surfaceBright: Colors.white,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFAF9F6),
    surfaceContainer: Colors.white,
    surfaceContainerHigh: const Color(0xFFEEEDE8),
    surfaceContainerHighest: const Color(0xFFE2E1DA),
    surfaceVariant: const Color(0xFFEEEDE8),
    card: Colors.white,
    primary: const Color(0xFFEA580C),
    onPrimary: Colors.white,
    primaryFixed: const Color(0xFFEA580C),
    primaryFixedDim: const Color(0xFFC2410C),
    onPrimaryFixed: Colors.white,
    onPrimaryFixedVariant: const Color(0xFF7C2D12),
    primaryContainer: const Color(0xFFFFECE5),
    onPrimaryContainer: const Color(0xFF7C2D12),
    secondary: const Color(0xFF786D66),
    onSecondary: Colors.white,
    secondaryFixed: const Color(0xFFF3EDE8),
    secondaryFixedDim: const Color(0xFF6B615A),
    onSecondaryFixed: const Color(0xFF2C221C),
    onSecondaryFixedVariant: const Color(0xFF4C3E37),
    secondaryContainer: const Color(0xFFF4ECE6),
    onSecondaryContainer: const Color(0xFF3B2E27),
    tertiary: const Color(0xFF497B55),
    onTertiary: Colors.white,
    tertiaryFixed: const Color(0xFFE3F0E4),
    tertiaryFixedDim: const Color(0xFF3F6A4A),
    onTertiaryFixed: const Color(0xFF17361E),
    onTertiaryFixedVariant: const Color(0xFF355641),
    tertiaryContainer: const Color(0xFFE4EFE4),
    onTertiaryContainer: const Color(0xFF294A30),
    error: const Color(0xFFB44A43),
    onError: Colors.white,
    errorContainer: const Color(0xFFF5E4E1),
    onErrorContainer: const Color(0xFF6D2420),
    textPrimary: const Color(0xFF171815),
    textSecondary: const Color(0xFF696A63),
    textDisabled: const Color(0xFF8D8E87),
    outline: const Color(0xFFD4D3CC),
    outlineVariant: const Color(0xFFE4E3DC),
    onSurface: const Color(0xFF171815),
    onSurfaceVariant: const Color(0xFF696A63),
    inverseSurface: const Color(0xFF171815),
    inverseOnSurface: const Color(0xFFF5F4F0),
    inversePrimary: const Color(0xFFFF9E6B),
    positive: const Color(0xFF3F6A4A),
    positiveSoft: const Color(0x1A56745E),
    negative: const Color(0xFFB44A43),
    negativeSoft: const Color(0x1AB44A43),
    warning: const Color(0xFF936727),
    coral: const Color(0xFFB44A43),
    teal: const Color(0xFF3C7772),
    mint: const Color(0xFF56745E),
    success: const Color(0xFF3F7750),
    coralTint: const Color(0x14B44A43),
    tealTint: const Color(0x143C7772),
    primaryTint: const Color(0x18EA580C),
    catFood: const Color(0xFF9B603A),
    catTransport: const Color(0xFF4F7384),
    catRent: const Color(0xFF9E6547),
    catGroceries: const Color(0xFF52765A),
    catUtilities: const Color(0xFF826B3B),
    catFun: const Color(0xFF925C75),
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
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      onPrimaryFixedVariant:
          onPrimaryFixedVariant ?? this.onPrimaryFixedVariant,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      onSecondaryFixedVariant:
          onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed ?? this.onTertiaryFixed,
      onTertiaryFixedVariant:
          onTertiaryFixedVariant ?? this.onTertiaryFixedVariant,
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
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t)!,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t)!,
      surfaceContainerHighest: Color.lerp(
          surfaceContainerHighest, other.surfaceContainerHighest, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      primaryFixedDim: Color.lerp(primaryFixedDim, other.primaryFixedDim, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      onPrimaryFixedVariant:
          Color.lerp(onPrimaryFixedVariant, other.onPrimaryFixedVariant, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim:
          Color.lerp(secondaryFixedDim, other.secondaryFixedDim, t)!,
      onSecondaryFixed:
          Color.lerp(onSecondaryFixed, other.onSecondaryFixed, t)!,
      onSecondaryFixedVariant: Color.lerp(
          onSecondaryFixedVariant, other.onSecondaryFixedVariant, t)!,
      secondaryContainer:
          Color.lerp(secondaryContainer, other.secondaryContainer, t)!,
      onSecondaryContainer:
          Color.lerp(onSecondaryContainer, other.onSecondaryContainer, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryFixed: Color.lerp(tertiaryFixed, other.tertiaryFixed, t)!,
      tertiaryFixedDim:
          Color.lerp(tertiaryFixedDim, other.tertiaryFixedDim, t)!,
      onTertiaryFixed: Color.lerp(onTertiaryFixed, other.onTertiaryFixed, t)!,
      onTertiaryFixedVariant:
          Color.lerp(onTertiaryFixedVariant, other.onTertiaryFixedVariant, t)!,
      tertiaryContainer:
          Color.lerp(tertiaryContainer, other.tertiaryContainer, t)!,
      onTertiaryContainer:
          Color.lerp(onTertiaryContainer, other.onTertiaryContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inverseOnSurface:
          Color.lerp(inverseOnSurface, other.inverseOnSurface, t)!,
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
