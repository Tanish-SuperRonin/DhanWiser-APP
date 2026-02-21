import 'package:flutter/material.dart';

class DhanWiserColors {
  // Primary Colors
  static const Color primary = Color(0xFF5048E5);
  static const Color primaryDark = Color(0xFF3F37B5); // Added based on Tailwind config in Add Expense screen

  // Background Colors
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundDark = Color(0xFF121121);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1C30); // Updated to match Tailwind config (was 1E1C2E in one, 1E1C30 in others, using 1E1C30 as primary dark surface)

  // Input Colors
  static const Color inputLight = Color(0xFFE8E8F3);
  static const Color inputDark = Color(0xFF2A2838);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F0E1B);
  static const Color textSecondaryLight = Color(0xFF6B7280); // gray-500
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // gray-400

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald custom
  static const Color error = Color(0xFFF43F5E);   // Coral custom
  static const Color warning = Color(0xFFF59E0B);

  // Neutral Colors
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
}