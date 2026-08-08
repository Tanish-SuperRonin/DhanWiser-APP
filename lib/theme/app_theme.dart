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
  static TextTheme get _textTheme =>
      GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
        displaySmall: GoogleFonts.manrope(
          color: DhanWiserColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineMedium: GoogleFonts.manrope(
          color: DhanWiserColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        titleLarge: GoogleFonts.manrope(
          color: DhanWiserColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        labelLarge: GoogleFonts.dmMono(
          color: DhanWiserColors.textPrimary,
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
        color: color ?? DhanWiserColors.textPrimary,
        letterSpacing: letterSpacing,
      );

  // ── Color scheme (premium dark lime) ──
  static ColorScheme get _colorScheme => ColorScheme.dark(
        primary: DhanWiserColors.primaryFixed,
        onPrimary: DhanWiserColors.onPrimary,
        primaryContainer: DhanWiserColors.primaryContainer,
        onPrimaryContainer: DhanWiserColors.onPrimaryContainer,
        secondary: DhanWiserColors.secondary,
        onSecondary: DhanWiserColors.onSecondary,
        secondaryContainer: DhanWiserColors.secondaryContainer,
        onSecondaryContainer: DhanWiserColors.onSecondaryContainer,
        tertiary: DhanWiserColors.tertiary,
        onTertiary: DhanWiserColors.onTertiary,
        tertiaryContainer: DhanWiserColors.tertiaryContainer,
        onTertiaryContainer: DhanWiserColors.onTertiaryContainer,
        error: DhanWiserColors.error,
        onError: DhanWiserColors.onError,
        errorContainer: DhanWiserColors.errorContainer,
        onErrorContainer: DhanWiserColors.onErrorContainer,
        surface: DhanWiserColors.surface,
        onSurface: DhanWiserColors.textPrimary,
        surfaceContainerLowest: DhanWiserColors.surfaceContainerLowest,
        surfaceContainerLow: DhanWiserColors.surfaceContainerLow,
        surfaceContainer: DhanWiserColors.surfaceContainer,
        surfaceContainerHigh: DhanWiserColors.surfaceContainerHigh,
        surfaceContainerHighest: DhanWiserColors.surfaceContainerHighest,
        onSurfaceVariant: DhanWiserColors.textSecondary,
        outline: DhanWiserColors.outline,
        outlineVariant: DhanWiserColors.outlineVariant,
        inverseSurface: DhanWiserColors.inverseSurface,
        onInverseSurface: DhanWiserColors.inverseOnSurface,
      );

  // ── Component themes ──

  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: DhanWiserColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: DhanWiserColors.textPrimary),
        titleTextStyle: _heading(fontSize: 20, fontWeight: FontWeight.w700),
      );

  static NavigationBarThemeData get _navBarTheme => NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: DhanWiserColors.primaryFixed,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DhanWiserColors.textDisabled,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
                color: DhanWiserColors.primaryFixed, size: 24);
          }
          return IconThemeData(
              color: DhanWiserColors.textDisabled, size: 24);
        }),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 0,
        color: DhanWiserColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DhanWiserTokens.radiusMedium,
          side: BorderSide(color: DhanWiserColors.outlineVariant, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DhanWiserColors.primaryFixed,
          foregroundColor: DhanWiserColors.onPrimaryFixed,
          disabledBackgroundColor:
              DhanWiserColors.primaryFixed.withValues(alpha: 0.38),
          disabledForegroundColor:
              DhanWiserColors.onPrimaryFixed.withValues(alpha: 0.38),
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

  static FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DhanWiserColors.primaryFixed,
          foregroundColor: DhanWiserColors.onPrimaryFixed,
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

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DhanWiserColors.textPrimary,
          side: BorderSide(color: DhanWiserColors.outlineVariant),
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

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DhanWiserColors.primaryFixed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
              borderRadius: DhanWiserTokens.radiusSmall),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: DhanWiserColors.primaryFixed,
        foregroundColor: DhanWiserColors.onPrimaryFixed,
        elevation: 4,
        highlightElevation: 2,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusMedium),
      );

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
        filled: true,
        fillColor: DhanWiserColors.surfaceContainerLow,
        hintStyle: GoogleFonts.manrope(
          color: DhanWiserColors.textDisabled,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.manrope(
          color: DhanWiserColors.textSecondary,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: DhanWiserColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(color: DhanWiserColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: DhanWiserColors.primaryFixed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: DhanWiserColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DhanWiserTokens.radiusSmall,
          borderSide: BorderSide(
            color: DhanWiserColors.error,
            width: 1.5,
          ),
        ),
      );

  static TabBarThemeData get _tabBarTheme => TabBarThemeData(
        indicatorColor: DhanWiserColors.primaryFixed,
        labelColor: DhanWiserColors.primaryFixed,
        unselectedLabelColor: DhanWiserColors.textSecondary,
        labelStyle:
            GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.label,
      );

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DhanWiserColors.onPrimaryFixed;
          }
          return DhanWiserColors.textDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DhanWiserColors.primaryFixed;
          }
          return DhanWiserColors.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return DhanWiserColors.outlineVariant;
        }),
      );

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerHigh,
        selectedColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
        labelStyle:
            GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
        side: BorderSide(color: DhanWiserColors.outlineVariant),
      );

  static DialogThemeData get _dialogTheme => DialogThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _heading(fontSize: 22, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: DhanWiserColors.textSecondary,
          height: 1.5,
        ),
      );

  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
        backgroundColor: DhanWiserColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSheet),
        dragHandleColor: DhanWiserColors.surfaceContainerLow,
        showDragHandle: true,
      );

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
            borderRadius: DhanWiserTokens.radiusSmall),
        backgroundColor: DhanWiserColors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.manrope(
          color: DhanWiserColors.textPrimary,
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

  static ThemeData _buildLightTheme() {
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
  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: DhanWiserColors.background,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      navigationBarTheme: _navBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      floatingActionButtonTheme: _fabTheme,
      inputDecorationTheme: _inputTheme,
      tabBarTheme: _tabBarTheme,
      switchTheme: _switchTheme,
      chipTheme: _chipTheme,
      dialogTheme: _dialogTheme,
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
      dividerTheme: DividerThemeData(
        color: DhanWiserColors.outlineVariant,
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
          color: DhanWiserColors.textPrimary,
        ).copyWith(inherit: false),
        subtitleTextStyle: GoogleFonts.manrope(
          fontSize: 14,
          color: DhanWiserColors.textSecondary,
        ).copyWith(inherit: false),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: DhanWiserColors.error,
        textColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DhanWiserColors.primaryFixed,
        linearTrackColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
        circularTrackColor:
            DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
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
