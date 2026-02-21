import 'package:flutter/material.dart';

class DhanWiserColors {
  // Primary — warm orange
  static const Color primary = Color(0xFFE8912C);        // Darker orange for readable contrast
  static const Color primaryLight = Color(0xFFFFCF9D);    // Light tint for backgrounds
  static const Color primaryDark = Color(0xFFD07A1A);     // Deep orange for pressed states

  // Accent — clearer financial indicators
  static const Color coral = Color(0xFFE05C4F);           // "You owe" — readable red
  static const Color teal = Color(0xFF2EAA7B);            // "Owed to you" — readable green
  static const Color mint = Color(0xFF38B27A);             // Success / settled

  // Pastel tints (for backgrounds/fills only, never for text)
  static const Color coralTint = Color(0xFFFFEBE9);       // Soft coral bg
  static const Color tealTint = Color(0xFFE1F5EC);        // Soft green bg
  static const Color primaryTint = Color(0xFFFFF3E0);     // Soft orange bg

  // Background
  static const Color backgroundLight = Color(0xFFF7F6F3);
  static const Color backgroundDark = Color(0xFF1A1D23);

  // Surface
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF22262E);

  // Elevated surface
  static const Color surfaceElevatedDark = Color(0xFF2A2F38);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);

  // Input — clear distinction from background
  static const Color inputLight = Color(0xFFEDE9E3);
  static const Color inputDark = Color(0xFF2A2F38);

  // Text — WCAG AA compliant contrast ratios
  static const Color textPrimaryLight = Color(0xFF1A1A1A);    // Near-black for max readability
  static const Color textSecondaryLight = Color(0xFF6B6560);  // 5.5:1 contrast on white
  static const Color textPrimaryDark = Color(0xFFF0F2F5);
  static const Color textSecondaryDark = Color(0xFF8B95A5);

  // Semantic — accessible on both light/dark
  static const Color success = Color(0xFF38B27A);
  static const Color error = Color(0xFFE05C4F);
  static const Color warning = Color(0xFFD4920A);

  // Neutrals — warm, with clear step contrast
  static const Color gray50 = Color(0xFFF7F6F3);
  static const Color gray100 = Color(0xFFEDE9E3);
  static const Color gray200 = Color(0xFFDBD6CF);
  static const Color gray300 = Color(0xFFC4BEB7);
  static const Color gray400 = Color(0xFF9E9890);
  static const Color gray500 = Color(0xFF6B6560);
  static const Color gray600 = Color(0xFF4A4540);
  static const Color gray700 = Color(0xFF3A3835);
  static const Color gray800 = Color(0xFF2A2F38);
  static const Color gray900 = Color(0xFF1A1D23);
}