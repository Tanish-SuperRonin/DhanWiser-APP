   import 'package:flutter/material.dart';

export '../theme/iconly_icons.dart';

/// Interactive Iconly Pro animated icon.
/// Emulates the 60 FPS motion & micro-interactions from Iconly Pro (web.iconly.pro/animations).
class IconlyAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isSelected;
  final double size;
  final Color? color;
  final Color? activeColor;
  final VoidCallback? onTap;
  final bool animateOnTap;
  final bool enableWobble;

  const IconlyAnimatedIcon({
    super.key,
    required this.icon,
    this.activeIcon,
    this.isSelected = false,
    this.size = 22,
    this.color,
    this.activeColor,
    this.onTap,
    this.animateOnTap = true,
    this.enableWobble = true,
  });

  @override
  State<IconlyAnimatedIcon> createState() => _IconlyAnimatedIconState();
}

class _IconlyAnimatedIconState extends State<IconlyAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Spring bounce like Iconly Pro animations
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
    ]).animate(_controller);

    // Subtle playful wobble rotation (-4 deg to +3 deg to 0)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.08, end: 0.06)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.06, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    if (widget.isSelected) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant IconlyAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isSelected && widget.isSelected) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.isSelected
        ? (widget.activeColor ?? Theme.of(context).colorScheme.primary)
        : (widget.color ?? Theme.of(context).unselectedWidgetColor);

    final displayIcon = (widget.isSelected && widget.activeIcon != null)
        ? widget.activeIcon!
        : widget.icon;

    Widget iconWidget = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: widget.enableWobble ? _rotationAnimation.value : 0.0,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              displayIcon,
              size: widget.size,
              color: effectiveColor,
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.animateOnTap) {
            _triggerAnimation();
          }
          widget.onTap?.call();
        },
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
