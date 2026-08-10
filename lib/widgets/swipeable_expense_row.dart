import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

/// A swipeable row widget that reveals Edit and Delete actions
/// when swiped left. Matches the gesture system from the new
/// DhanWiser React frontend (motion/react swipe behavior).
class SwipeableExpenseRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String title; // For delete confirmation dialog

  const SwipeableExpenseRow({
    super.key,
    required this.child,
    required this.onDelete,
    required this.onEdit,
    required this.title,
  });

  @override
  State<SwipeableExpenseRow> createState() => _SwipeableExpenseRowState();
}

class _SwipeableExpenseRowState extends State<SwipeableExpenseRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double _dragExtent = 0;
  static const double _actionWidth = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _dragExtent = _dragExtent.clamp(-_actionWidth, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragExtent < -80 || velocity < -300) {
      // Snap open
      _animateTo(-_actionWidth);
    } else {
      // Snap closed
      _animateTo(0);
    }
  }

  void _animateTo(double target) {
    _slideAnimation = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset(target, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _dragExtent = target);
      }
    });
  }

  void _close() => _animateTo(0);

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: DhanWiserColors.of(context).surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).negativeSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: DhanWiserColors.of(context).negative,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Expense?',
              style: DhanWiserTextStyles.buttonLarge(context)
                  .copyWith(color: DhanWiserColors.of(context).textPrimary),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: DhanWiserTextStyles.caption(context).copyWith(
                    color: DhanWiserColors.of(context).textSecondary, height: 1.5),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: "'${widget.title}'",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.of(context).textPrimary,
                    ),
                  ),
                  const TextSpan(text: '? This action cannot be undone.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: PremiumOutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _close();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: DhanWiserColors.of(context).outline),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: DhanWiserColors.of(context).textPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: PremiumFilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.onDelete();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: DhanWiserColors.of(context).negative,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Delete',
                        style: Theme.of(context).textTheme.titleSmall!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Background action buttons (revealed on swipe)
          Positioned.fill(
            child: Container(
              color: DhanWiserColors.of(context).surfaceContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit button
                  GestureDetector(
                    onTap: () {
                      _close();
                      widget.onEdit();
                    },
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: DhanWiserColors.of(context).surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: DhanWiserColors.of(context).outline),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: DhanWiserColors.of(context).textPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EDIT',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color: DhanWiserColors.of(context).textSecondary,
                                    letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Delete button
                  GestureDetector(
                    onTap: _showDeleteConfirmation,
                    child: Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: DhanWiserColors.of(context).negative,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'DELETE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color: DhanWiserColors.of(context).negative,
                                    letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Foreground swipeable content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = _controller.isAnimating
                  ? _slideAnimation.value
                  : Offset(_dragExtent, 0);
              return Transform.translate(
                offset: offset,
                child: child,
              );
            },
            child: GestureDetector(
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: Container(
                decoration: BoxDecoration(
                  color: DhanWiserColors.of(context).background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
