import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/design_tokens.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

/// A quiet elevated container for information that belongs together.
class DhanWiserSurface extends StatefulWidget {
  const DhanWiserSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DhanWiserTokens.space5),
    this.margin,
    this.tint,
    this.radius = DhanWiserTokens.radiusMedium,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final BorderRadius radius;
  final VoidCallback? onTap;

  @override
  State<DhanWiserSurface> createState() => _DhanWiserSurfaceState();
}

class _DhanWiserSurfaceState extends State<DhanWiserSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.tint ?? colors.surfaceContainer,
        borderRadius: widget.radius,
        border: Border.all(color: colors.outlineVariant, width: 1.0),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0x060F172A),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: widget.child,
    );
    if (widget.onTap == null) return surface;
    return AnimatedScale(
      scale: _pressed ? .982 : 1,
      duration: DhanWiserTokens.motionFast,
      curve: DhanWiserTokens.motionCurve,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          borderRadius: widget.radius,
          splashColor: colors.primaryFixed.withValues(alpha: 0.08),
          highlightColor: colors.primaryFixed.withValues(alpha: 0.04),
          child: surface,
        ),
      ),
    );
  }
}

/// Consistent section heading used for lists, summaries, and grouped controls.
class DhanWiserSectionHeader extends StatelessWidget {
  const DhanWiserSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.actionLabel,
    this.eyebrow,
  });

  final String title;
  final VoidCallback? action;
  final String? actionLabel;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                Text(
                  eyebrow!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: DhanWiserColors.of(context).textDisabled, letterSpacing: 1.1),
                ),
                const SizedBox(height: DhanWiserTokens.space1),
              ],
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        if (action != null)
          PremiumTextButton(onPressed: action, child: Text(actionLabel ?? 'View all')),
      ],
    );
  }
}

/// An icon-only control with a shared hit target and outlined surface.
class DhanWiserIconButton extends StatelessWidget {
  const DhanWiserIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: DhanWiserColors.of(context).surfaceContainer,
        border: Border.all(color: DhanWiserColors.of(context).outlineVariant),
        borderRadius: DhanWiserTokens.radiusSmall,
      ),
      child: PremiumIconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
      ),
    );
  }
}
