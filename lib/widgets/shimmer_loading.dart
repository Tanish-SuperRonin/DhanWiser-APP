import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';

/// Premium shimmer loaders matching the dark mode amber theme.
class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DhanWiserColors.surfaceContainerHigh,
      highlightColor: DhanWiserColors.surfaceContainerHighest,
      period: const Duration(milliseconds: 1200), // Fast, fluid wave
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double radius;

  const ShimmerCircle({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ExpenseListShimmer extends StatelessWidget {
  const ExpenseListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 8,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DhanWiserColors.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const ShimmerCircle(radius: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 120, height: 16, borderRadius: 4),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 80, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                const ShimmerBox(width: 60, height: 20, borderRadius: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
