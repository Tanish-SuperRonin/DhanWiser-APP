import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'colors.dart';
import 'design_tokens.dart';

/// DhanWiser Premium Theme — v3 (Lime & Violet)
///
/// Dark mode only. Lime green (#C0F500) and Violet (#C9BFFF) on deep
/// black (#131315) surfaces. Uses Inter for body and Plus Jakarta Sans for headings.
class DhanWiserTheme {
  DhanWiserTheme._();

  // ── Body text: Inter ──
  static TextTheme _textTheme(DhanWiserColors colors) =>
      GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displaySmall: GoogleFonts.manrope(
          color: colors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: GoogleFonts.manrope(
          color: colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: GoogleFonts.manrope(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        labelLarge: GoogleFonts.dmMono(
          color: colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );

  // ── Heading font: Plus Jakarta Sans ──
  static TextStyle _heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.3,
  }) =>
      GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? DhanWiserColors.dark.textPrimary,
        letterSpacing: letterSpacing,
      );

  // ── Color scheme (premium dark lime) ──
  static ColorScheme _colorScheme(DhanWiserColors colors) => ColorScheme.dark(
        primary: colors.primaryFixed,
        onPrimary: colors.onPrimary,
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

  static AppBarTheme _appBarTheme(DhanWiserColors colors) => AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: _heading(fontSize: 20, fontWeight: FontWeight.w700),
      );

  static NavigationBarThemeData _navBarTheme(DhanWiserColors colors) => NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryFixed.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.primaryFixed,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.textDisabled,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primaryFixed, size: 24);
          }
          return IconThemeData(color: colors.textDisabled, size: 24);
        }),
      );

  static CardThemeData _cardTheme(DhanWiserColors colors) => CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DhanWiserTokens.radiusMedium,
          side: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(DhanWiserColors colors) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryFixed,
          foregroundColor: colors.onPrimaryFixed,
          disabledBackgroundColor:
              colors.primaryFixed.withValues(alpha: 0.38),
          disabledForegroundColor:
              colors.onPrimaryFixed.withValues(alpha: 0.38),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusSmall),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static FilledButtonThemeData _filledButtonTheme(DhanWiserColors colors) => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primaryFixed,
          foregroundColor: colors.onPrimaryFixed,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusSmall),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(DhanWiserColors colors) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.outlineVariant),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusSmall),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData _textButtonTheme(DhanWiserColors colors) => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primaryFixed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusSmall),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static FloatingActionButtonThemeData _fabTheme(DhanWiserColors colors) =>
      FloatingActionButtonThemeData(
        backgroundColor: colors.primaryFixed,
        foregroundColor: colors.onPrimaryFixed,
        elevation: 4,
        highlightElevation: 2,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusMedium),
      );

  static InputDecorationTheme _inputTheme(DhanWiserColors colors) => InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLow,
        hintStyle: GoogleFonts.manrope(
          color: colors.textDisabled,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.manrope(
          color: colors.textSecondary,
          fontSize: 15,
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

  static TabBarThemeData _tabBarTheme(DhanWiserColors colors) => TabBarThemeData(
        indicatorColor: colors.primaryFixed,
        labelColor: colors.primaryFixed,
        unselectedLabelColor: colors.textSecondary,
        labelStyle:
            GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      );

  static SwitchThemeData _switchTheme(DhanWiserColors colors) => SwitchThemeData(
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
        labelStyle:
            GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
        side: BorderSide(color: colors.outlineVariant),
      );

  static DialogThemeData _dialogTheme(DhanWiserColors colors) => DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _heading(fontSize: 22, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: colors.textSecondary,
          height: 1.5,
        ),
      );

  static BottomSheetThemeData _bottomSheetTheme(DhanWiserColors colors) => BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSheet),
        dragHandleColor: colors.surfaceContainerLow,
        showDragHandle: true,
      );

  static SnackBarThemeData _snackBarTheme(DhanWiserColors colors) => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSmall),
        backgroundColor: colors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.manrope(
          color: colors.textPrimary,
          fontSize: 14,
        ),
      );

  // ──────────────────────────────────────────────
  // Light Theme (maps to dark — dark mode only app)
  // ──────────────────────────────────────────────
  static ThemeData get lightTheme => _buildLightTheme();

  // ──────────────────────────────────────────────
  // Dark Theme
  // ──────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme();

  static ThemeData _buildLightTheme() { final colors = DhanWiserColors.light;
    const ink = Color(0xFF171B20);
    const lime = Color(0xFF587900);
    const limeContainer = Color(0xFFE5F4B8);
    const surface = Color(0xFFFFFFFF);
    const canvas = Color(0xFFF8F9F7);
    const line = Color(0xFFDCE1DD);
    final scheme = ColorScheme.fromSeed(
      seedColor: lime,
      brightness: Brightness.light,
      primary: lime,
      onPrimary: Colors.white,
      primaryContainer: limeContainer,
      onPrimaryContainer: const Color(0xFF253600),
      surface: surface,
      onSurface: ink,
      outlineVariant: line,
    );
    return ThemeData(
      useMaterial3: true,
      extensions: [colors],
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme:
          GoogleFonts.manropeTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DhanWiserTokens.radiusMedium,
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF4F6F2),
        border: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: line),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: limeContainer,
      ),
      dividerTheme: const DividerThemeData(color: line),
      listTileTheme: const ListTileThemeData(textColor: ink, iconColor: lime),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── Single theme builder (always dark) ──
  static ThemeData _buildTheme() { final colors = DhanWiserColors.dark;
    return ThemeData(
      useMaterial3: true,
      extensions: [colors],
      brightness: Brightness.dark,
      colorScheme: _colorScheme(colors),
      scaffoldBackgroundColor: colors.background,
      textTheme: _textTheme(colors),
      appBarTheme: _appBarTheme(colors),
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
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ).copyWith(inherit: false),
        subtitleTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: colors.textSecondary,
        ).copyWith(inherit: false),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colors.error,
        textColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primaryFixed,
        linearTrackColor: colors.primaryFixed.withValues(alpha: 0.15),
        circularTrackColor:
            colors.primaryFixed.withValues(alpha: 0.15),
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
