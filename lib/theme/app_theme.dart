import 'package:flutter/material.dart';
import 'colors.dart';

class DhanWiserTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: DhanWiserColors.primary,
    scaffoldBackgroundColor: DhanWiserColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: DhanWiserColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: ColorScheme.light(
      primary: DhanWiserColors.primary,
      secondary: DhanWiserColors.success,
      surface: DhanWiserColors.surfaceLight,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: DhanWiserColors.primary,
    scaffoldBackgroundColor: DhanWiserColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: DhanWiserColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
    ),
    colorScheme: ColorScheme.dark(
      primary: DhanWiserColors.primary,
      secondary: DhanWiserColors.success,
      surface: DhanWiserColors.surfaceDark,
    ),
    useMaterial3: true,
  );
}