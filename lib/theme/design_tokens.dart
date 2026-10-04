import 'package:flutter/material.dart';

/// Layout and motion values shared by every DhanWiser screen.
abstract final class DhanWiserTokens {
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets pagePaddingWide =
      EdgeInsets.symmetric(horizontal: 24);

  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusMedium =
      BorderRadius.all(Radius.circular(18));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(100));
  static const BorderRadius radiusSheet =
      BorderRadius.vertical(top: Radius.circular(32));

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionStandard = Duration(milliseconds: 280);
  static const Curve motionCurve = Curves.easeOutCubic;
}
