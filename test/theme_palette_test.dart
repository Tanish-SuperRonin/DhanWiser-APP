import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhanwiser_fixed/theme/colors.dart';

void main() {
  test('palette switches every core surface between dark and light mode', () {
    
    expect(DhanWiserColors.dark.background, const Color(0xFFF8F9F7));
    expect(DhanWiserColors.dark.surface, Colors.white);
    expect(DhanWiserColors.dark.textPrimary, const Color(0xFF171B20));
    expect(DhanWiserColors.dark.primaryFixed, const Color(0xFF587900));

    
    expect(DhanWiserColors.dark.background, const Color(0xFF0B0D10));
    expect(DhanWiserColors.dark.surface, const Color(0xFF111419));
    expect(DhanWiserColors.dark.textPrimary, const Color(0xFFF5F7FA));
    expect(DhanWiserColors.dark.primaryFixed, const Color(0xFFC9F542));
  });
}
