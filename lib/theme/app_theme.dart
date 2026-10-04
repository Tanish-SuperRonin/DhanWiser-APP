import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'colors.dart';
import 'design_tokens.dart';

/// DhanWiser Radiant Tangerine & Porcelain theme with modern warm aesthetics.
class DhanWiserTheme {
  DhanWiserTheme._();

  // ── Unified Typography: Plus Jakarta Sans ──
  static TextTheme _textTheme(DhanWiserColors colors, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 29,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        color: colors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: colors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: colors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        color: colors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  static TextStyle _heading(
    DhanWiserColors colors, {
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.3,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? colors.textPrimary,
        letterSpacing: letterSpacing,
      );

  // ── Color scheme ──
  static ColorScheme _colorScheme(
          DhanWiserColors colors, Brightness brightness) =>
      ColorScheme(
        brightness: brightness,
        primary: colors.primaryFixed,
        onPrimary: colors.onPrimaryFixed,
        primaryContainer: colors.primaryContainer,
        onPrimaryContainer: colors.onPrimaryContainer,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondaryContainer,
        onSecondaryContainer: colors.onSecondaryContainer,
        tertiary: colors.tertiary,
        onTertiary: colors.onTertiary,
        tertiaryContainer: colors.tertiaryContainer,
        onTertiaryContainer: colors.onTertiaryContainer,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.errorContainer,
        onErrorContainer: colors.onErrorContainer,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerLowest: colors.surfaceContainerLowest,
        surfaceContainerLow: colors.surfaceContainerLow,
        surfaceContainer: colors.surfaceContainer,
        surfaceContainerHigh: colors.surfaceContainerHigh,
        surfaceContainerHighest: colors.surfaceContainerHighest,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.outline,
        outlineVariant: colors.outlineVariant,
        inverseSurface: colors.inverseSurface,
        onInverseSurface: colors.inverseOnSurface,
      );

  // ── Component themes ──

  static AppBarTheme _appBarTheme(
          DhanWiserColors colors, Brightness brightness) =>
      AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle:
            _heading(colors, fontSize: 20, fontWeight: FontWeight.w700),
      );

  static NavigationBarThemeData _navBarTheme(DhanWiserColors colors) =>
      NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.primary,
              letterSpacing: 0.2,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textDisabled,
            letterSpacing: 0.2,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 22);
          }
          return IconThemeData(color: colors.textDisabled, size: 22);
        }),
      );

  static CardThemeData _cardTheme(DhanWiserColors colors) => CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DhanWiserTokens.radiusMedium,
          side: BorderSide(color: colors.outlineVariant, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(DhanWiserColors colors) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryFixed,
          foregroundColor: colors.onPrimaryFixed,
          disabledBackgroundColor: colors.primaryFixed.withValues(alpha: 0.38),
          disabledForegroundColor:
              colors.onPrimaryFixed.withValues(alpha: 0.38),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusPill),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      );

  static FilledButtonThemeData _filledButtonTheme(DhanWiserColors colors) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryFixed,
          foregroundColor: colors.onPrimaryFixed,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusPill),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(DhanWiserColors colors) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.outlineVariant, width: 1.2),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusPill),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme(DhanWiserColors colors) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusPill),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  static FloatingActionButtonThemeData _fabTheme(DhanWiserColors colors) =>
      FloatingActionButtonThemeData(
        backgroundColor: colors.primaryFixed,
        foregroundColor: colors.onPrimaryFixed,
        elevation: 6,
        highlightElevation: 3,
        shape: const CircleBorder(),
      );

  static InputDecorationTheme _inputTheme(DhanWiserColors colors) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: colors.textDisabled,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: colors.textSecondary,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: colors.primaryFixed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: colors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5,
          ),
        ),
      );

  static TabBarThemeData _tabBarTheme(DhanWiserColors colors) =>
      TabBarThemeData(
        indicatorColor: colors.primary,
        labelColor: colors.primary,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      );

  static SwitchThemeData _switchTheme(DhanWiserColors colors) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.onPrimaryFixed;
          }
          return colors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primaryFixed;
          }
          return colors.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colors.outlineVariant;
        }),
      );

  static ChipThemeData _chipTheme(DhanWiserColors colors) => ChipThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        selectedColor: colors.primaryFixed.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
        side: BorderSide(color: colors.outlineVariant),
      );

  static DialogThemeData _dialogTheme(DhanWiserColors colors) =>
      DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle:
            _heading(colors, fontSize: 22, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.5,
        ),
      );

  static BottomSheetThemeData _bottomSheetTheme(DhanWiserColors colors) =>
      BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSheet),
        dragHandleColor: colors.surfaceContainerLow,
        showDragHandle: true,
      );

  static SnackBarThemeData _snackBarTheme(DhanWiserColors colors) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSmall),
        backgroundColor: colors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: colors.textPrimary,
          fontSize: 14,
        ),
      );

  // ──────────────────────────────────────────────
  // Light Theme
  // ──────────────────────────────────────────────
  static ThemeData get lightTheme =>
      _buildTheme(DhanWiserColors.light, Brightness.light);

  // ──────────────────────────────────────────────
  // Dark Theme
  // ──────────────────────────────────────────────
  static ThemeData get darkTheme =>
      _buildTheme(DhanWiserColors.dark, Brightness.dark);

  static ThemeData _buildTheme(DhanWiserColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      extensions: [colors],
      brightness: brightness,
      colorScheme: _colorScheme(colors, brightness),
      scaffoldBackgroundColor: colors.background,
      textTheme: _textTheme(colors, brightness),
      appBarTheme: _appBarTheme(colors, brightness),
      navigationBarTheme: _navBarTheme(colors),
      cardTheme: _cardTheme(colors),
      elevatedButtonTheme: _elevatedButtonTheme(colors),
      filledButtonTheme: _filledButtonTheme(colors),
      outlinedButtonTheme: _outlinedButtonTheme(colors),
      textButtonTheme: _textButtonTheme(colors),
      floatingActionButtonTheme: _fabTheme(colors),
      inputDecorationTheme: _inputTheme(colors),
      tabBarTheme: _tabBarTheme(colors),
      switchTheme: _switchTheme(colors),
      chipTheme: _chipTheme(colors),
      dialogTheme: _dialogTheme(colors),
      bottomSheetTheme: _bottomSheetTheme(colors),
      snackBarTheme: _snackBarTheme(colors),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSmall),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ).copyWith(inherit: false),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: colors.textSecondary,
        ).copyWith(inherit: false),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colors.error,
        textColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.primary.withValues(alpha: 0.15),
        circularTrackColor: colors.primary.withValues(alpha: 0.15),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
