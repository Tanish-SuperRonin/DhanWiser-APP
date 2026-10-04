import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dhanwiser_fixed/theme/colors.dart';

void main() {
  test('palette switches every core surface between dark and light mode', () {
    
    expect(DhanWiserColors.light.background, const Color(0xFFF5F4F0));
    expect(DhanWiserColors.light.surface, Colors.white);
    expect(DhanWiserColors.light.textPrimary, const Color(0xFF171815));
    expect(DhanWiserColors.light.primaryFixed, const Color(0xFFEA580C));

    expect(DhanWiserColors.dark.background, const Color(0xFF11120F));
    expect(DhanWiserColors.dark.surface, const Color(0xFF191A17));
    expect(DhanWiserColors.dark.textPrimary, const Color(0xFFF1F0EA));
    expect(DhanWiserColors.dark.primaryFixed, const Color(0xFFFF7D3B));
  });
}
