import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Blob
        Container(
          width: 256,
          height: 256,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.primaryContainer.withValues(alpha: isDark ? 0.2 : 0.4),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.1 : 0.2),
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
                ? cs.surfaceContainerHigh
                : cs.surfaceContainerLowest,
            border: Border.all(
              color: isDark
                  ? cs.outlineVariant.withValues(alpha: 0.2)
                  : cs.outlineVariant,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.2),
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
                  ? cs.surfaceContainerHigh
                  : cs.surfaceContainerLowest,
              border: Border.all(
                color: cs.outlineVariant,
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
              color: cs.primary,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }
}