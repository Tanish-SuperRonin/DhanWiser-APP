import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium, subtle bouncing button wrapper.
/// Shrinks slightly (to 96%) very quickly (100ms) with light haptic feedback.
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;

  const BouncingButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96, // Very subtle scale, not cheap/exaggerated
    this.duration = const Duration(milliseconds: 100), // Fast and snappy
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      onLongPress: () {
        if (widget.onLongPress != null) {
          HapticFeedback.mediumImpact();
          widget.onLongPress!();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}


// ============================================================================
// PREMIUM BUTTON WRAPPERS
// ============================================================================

class PremiumElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget child;

  const PremiumElevatedButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: ElevatedButton(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class PremiumElevatedButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget icon;
  final Widget label;

  const PremiumElevatedButtonIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: ElevatedButton.icon(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          icon: icon,
          label: label,
        ),
      ),
    );
  }
}

class PremiumTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget child;

  const PremiumTextButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: TextButton(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class PremiumTextButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget icon;
  final Widget label;

  const PremiumTextButtonIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: TextButton.icon(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          icon: icon,
          label: label,
        ),
      ),
    );
  }
}

class PremiumOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget child;

  const PremiumOutlinedButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: OutlinedButton(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class PremiumOutlinedButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget icon;
  final Widget label;

  const PremiumOutlinedButtonIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: OutlinedButton.icon(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          icon: icon,
          label: label,
        ),
      ),
    );
  }
}

class PremiumFilledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget child;

  const PremiumFilledButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: FilledButton(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

class PremiumFilledButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final Widget icon;
  final Widget label;

  const PremiumFilledButtonIcon({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: IgnorePointer(
        child: FilledButton.icon(
          onPressed: onPressed != null ? () {} : null,
          onLongPress: onLongPress != null ? () {} : null,
          style: style,
          icon: icon,
          label: label,
        ),
      ),
    );
  }
}

class PremiumIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;
  final double? iconSize;
  final double? splashRadius;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final String? tooltip;
  final ButtonStyle? style;

  const PremiumIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.iconSize,
    this.splashRadius,
    this.padding,
    this.constraints,
    this.alignment,
    this.tooltip,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: onPressed,
      child: IgnorePointer(
        child: IconButton(
          onPressed: onPressed != null ? () {} : null,
          icon: icon,
          color: color,
          iconSize: iconSize,
          splashRadius: splashRadius,
          padding: padding,
          constraints: constraints,
          alignment: alignment,
          tooltip: tooltip,
          style: style,
        ),
      ),
    );
  }
}
