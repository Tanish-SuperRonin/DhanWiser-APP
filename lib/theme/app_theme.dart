import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'colors.dart';

/// DhanWiser Premium Theme — v2 (Warm Amber)
///
/// Dark mode only. Warm amber (#F5A623) primary with deep
/// obsidian (#0F0E0D) surfaces. Uses DM Sans for body and
/// Plus Jakarta Sans for headings (via Google Fonts).
class DhanWiserTheme {
  DhanWiserTheme._();

  // ── Body text: DM Sans ──
  static TextTheme get _textTheme =>
      GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme);

  // ── Heading font: Plus Jakarta Sans ──
  static TextStyle _heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = DhanWiserColors.textPrimaryDark,
    double letterSpacing = -0.3,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ── Color scheme (premium warm dark) ──
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
        surface: DhanWiserColors.surfaceDark,
        onSurface: DhanWiserColors.textPrimaryDark,
        surfaceContainerLowest: DhanWiserColors.surfaceContainerLowestDark,
        surfaceContainerLow: DhanWiserColors.surfaceContainerLowDark,
        surfaceContainer: DhanWiserColors.surfaceContainerDark,
        surfaceContainerHigh: DhanWiserColors.surfaceContainerHighDark,
        surfaceContainerHighest: DhanWiserColors.surfaceContainerHighestDark,
        onSurfaceVariant: DhanWiserColors.textSecondaryDark,
        outline: DhanWiserColors.outlineDark,
        outlineVariant: DhanWiserColors.outlineVariantDark,
        inverseSurface: DhanWiserColors.textPrimaryDark,
        onInverseSurface: DhanWiserColors.backgroundDark,
      );

  // ── Component themes ──

  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: DhanWiserColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: DhanWiserColors.textPrimaryDark),
        titleTextStyle: _heading(fontSize: 20, fontWeight: FontWeight.w600),
      );

  static NavigationBarThemeData get _navBarTheme => NavigationBarThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerDark,
        elevation: 0,
        height: 80,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DhanWiserColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: DhanWiserColors.primary,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: DhanWiserColors.textMuted,
            letterSpacing: 0.5,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                color: DhanWiserColors.primary, size: 24);
          }
          return const IconThemeData(
              color: DhanWiserColors.textMuted, size: 24);
        }),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 0,
        color: DhanWiserColors.surfaceContainerDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: DhanWiserColors.outlineDark, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
      );

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DhanWiserColors.primary,
          foregroundColor: DhanWiserColors.onPrimary,
          disabledBackgroundColor:
              DhanWiserColors.primary.withValues(alpha: 0.38),
          disabledForegroundColor:
              DhanWiserColors.onPrimary.withValues(alpha: 0.38),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  static FilledButtonThemeData get _filledButtonTheme =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DhanWiserColors.primary,
          foregroundColor: DhanWiserColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DhanWiserColors.primary,
          side: const BorderSide(color: DhanWiserColors.outlineDark),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DhanWiserColors.primary,
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
        backgroundColor: DhanWiserColors.primary,
        foregroundColor: DhanWiserColors.onPrimary,
        elevation: 4,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  static InputDecorationTheme get _inputTheme => InputDecorationTheme(
        filled: true,
        fillColor: DhanWiserColors.surfaceContainerDark,
        hintStyle: GoogleFonts.dmSans(
          color: DhanWiserColors.textMuted,
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.dmSans(
          color: DhanWiserColors.textSecondaryDark,
          fontSize: 15,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DhanWiserColors.outlineDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DhanWiserColors.outlineDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DhanWiserColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DhanWiserColors.negative,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: DhanWiserColors.negative,
            width: 2,
          ),
        ),
      );

  static TabBarThemeData get _tabBarTheme => TabBarThemeData(
        indicatorColor: DhanWiserColors.primary,
        labelColor: DhanWiserColors.primary,
        unselectedLabelColor: DhanWiserColors.textSecondaryDark,
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
            return DhanWiserColors.backgroundDark;
          }
          return DhanWiserColors.outlineDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DhanWiserColors.primary;
          }
          return DhanWiserColors.surfaceContainerHighestDark;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return DhanWiserColors.outlineDark;
        }),
      );

  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerHighDark,
        selectedColor: DhanWiserColors.primary.withValues(alpha: 0.15),
        labelStyle:
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
        side: const BorderSide(color: DhanWiserColors.outlineDark),
      );

  static DialogThemeData get _dialogTheme => DialogThemeData(
        backgroundColor: DhanWiserColors.surfaceContainerHighDark,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: _heading(fontSize: 22, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: DhanWiserColors.textSecondaryDark,
          height: 1.5,
        ),
      );

  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
        backgroundColor: DhanWiserColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: DhanWiserColors.outlineDark,
        showDragHandle: true,
      );

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: DhanWiserColors.surfaceContainerHighestDark,
        contentTextStyle: GoogleFonts.dmSans(
          color: DhanWiserColors.textPrimaryDark,
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
      scaffoldBackgroundColor: DhanWiserColors.backgroundDark,
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
        color: DhanWiserColors.outlineDark,
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
          color: DhanWiserColors.textPrimaryDark,
        ),
        subtitleTextStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: DhanWiserColors.textSecondaryDark,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: DhanWiserColors.negative,
        textColor: Colors.white,
        textStyle:
            GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DhanWiserColors.primary,
        linearTrackColor: DhanWiserColors.primary.withValues(alpha: 0.15),
        circularTrackColor: DhanWiserColors.primary.withValues(alpha: 0.15),
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