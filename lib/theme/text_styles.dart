import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DhanWiserTextStyles {
  // Display Styles
  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );
  }

  // Headline Styles
  static TextStyle headline1(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );
  }

  static TextStyle headline2(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
  }

  static TextStyle bodyRegular(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );
  }

  // Caption Styles
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
  }

  // Button Styles
  static TextStyle buttonLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );
  }

  // Overline Styles
  static TextStyle overline(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.0,
      letterSpacing: 1.2,
    );
  }
}
