import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'colors.dart';

/// DhanWiser Premium Theme — v3 (Lime & Violet)
///
/// Dark mode only. Lime green (#C0F500) and Violet (#C9BFFF) on deep
/// black (#131315) surfaces. Uses Inter for body and Plus Jakarta Sans for headings.
class DhanWiserTheme {
  DhanWiserTheme._();

  // ── Body text: Inter ──
  static TextTheme get _textTheme =>
      GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  // ── Heading font: Plus Jakarta Sans ──
  static TextStyle _heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = DhanWiserColors.textPrimary,
    double letterSpacing = -0.3,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── Color scheme (premium dark lime) ──
  static ColorScheme get _colorScheme => ColorScheme.dark(
        primary: DhanWiserColors.primary,
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
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: DhanWiserColors.textPrimary),
        titleTextStyle: _heading(fontSize: 20, fontWeight: FontWeight.w600),
      );

  static NavigationBarThemeData get _navBarTheme => NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 68,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: DhanWiserColors.primaryFixed,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DhanWiserColors.textDisabled,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                color: DhanWiserColors.primaryFixed, size: 24);
          }
          return const IconThemeData(
              color: DhanWiserColors.textDisabled, size: 24);
        }),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 0,
        color: DhanWiserColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DhanWiserColors.outlineVariant, width: 0.5),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static FilledButtonThemeData get _filledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DhanWiserColors.primaryFixed,
          foregroundColor: DhanWiserColors.onPrimaryFixed,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DhanWiserColors.textPrimary,
          side: const BorderSide(color: DhanWiserColors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DhanWiserColors.primaryFixed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.plusJakartaSans(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
        filled: true,
        fillColor: DhanWiserColors.surfaceContainerLow,
        hintStyle: GoogleFonts.inter(
          color: DhanWiserColors.textDisabled,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.inter(
          color: DhanWiserColors.textSecondary,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DhanWiserColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DhanWiserColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DhanWiserColors.primaryFixed,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DhanWiserColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
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
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 14),
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
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        side: const BorderSide(color: DhanWiserColors.outlineVariant),
      );

  static DialogThemeData get _dialogTheme => DialogThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _heading(fontSize: 22, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.inter(
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        dragHandleColor: DhanWiserColors.surfaceContainerLow,
        showDragHandle: true,
      );

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: DhanWiserColors.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.inter(
          color: DhanWiserColors.textPrimary,
          fontSize: 14,
        ),
      );

  // ──────────────────────────────────────────────
  // Light Theme (maps to dark — dark mode only app)
  // ──────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme();

  // ──────────────────────────────────────────────
  // Dark Theme
  // ──────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme();

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
      dividerTheme: const DividerThemeData(
        color: DhanWiserColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: DhanWiserColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: DhanWiserColors.textSecondary,
        ),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: DhanWiserColors.error,
        textColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DhanWiserColors.primaryFixed,
        linearTrackColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
        circularTrackColor: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
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