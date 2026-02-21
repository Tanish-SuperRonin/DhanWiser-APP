import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Reusable Onboarding Card
class OnboardingCard extends StatelessWidget {
  final String imageUrl;
  final IconData floatingIcon;
  final bool isDark;

  const OnboardingCard({
    super.key,
    required this.imageUrl,
    required this.floatingIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Blob
        Container(
          width: 256,
          height: 256,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? DhanWiserColors.primary.withValues(alpha: 0.1)
                : DhanWiserColors.primary.withValues(alpha: 0.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? DhanWiserColors.primary.withValues(alpha: 0.1)
                    : DhanWiserColors.primary.withValues(alpha: 0.2),
                blurRadius: 48,
              ),
            ],
          ),
        ),

        // Main Card
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark
                ? DhanWiserColors.surfaceDark.withValues(alpha: 0.5)
                : DhanWiserColors.surfaceLight,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : DhanWiserColors.gray100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? DhanWiserColors.primary.withValues(alpha: 0.2)
                    : DhanWiserColors.primary.withValues(alpha: 0.3),
                blurRadius: 48,
                spreadRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Floating Icon
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? DhanWiserColors.surfaceDark
                  : DhanWiserColors.surfaceLight,
              border: Border.all(
                color: isDark
                    ? DhanWiserColors.gray700
                    : DhanWiserColors.gray200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              floatingIcon,
              color: DhanWiserColors.primary,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}