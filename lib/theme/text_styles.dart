import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DhanWiserTextStyles {
  // Display Styles
  static TextStyle displayLarge(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // Headline Styles
  static TextStyle headline1(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -0.8,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle headline2(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.5,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: -0.2,
    );
  }

  static TextStyle bodyRegular(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: -0.1,
    );
  }

  // Caption Styles
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  // Button Styles
  static TextStyle buttonLarge(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 0.1,
    );
  }

  // Overline Styles
  static TextStyle overline(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: 1.0,
    );
  }

  // Title and Subheading Styles
  static TextStyle title1(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    );
  }

  static TextStyle title2(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );
  }

  static TextStyle bodyBold(BuildContext context) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    );
  }

  // Numeric amount style
  static TextStyle numericAmount(BuildContext context, {double fontSize = 16, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

