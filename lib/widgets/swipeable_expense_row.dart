import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

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
        backgroundColor: DhanWiserColors.surfaceContainerHighDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DhanWiserColors.negativeSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: DhanWiserColors.negative,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Expense?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DhanWiserColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: DhanWiserColors.textSecondaryDark,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: "'${widget.title}'",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.textPrimaryDark,
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
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _close();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: DhanWiserColors.outlineDark),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DhanWiserColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.onDelete();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: DhanWiserColors.negative,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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
              color: DhanWiserColors.surfaceContainerDark,
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
                              color: DhanWiserColors.surfaceContainerHighestDark,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: DhanWiserColors.outlineDark),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: DhanWiserColors.textPrimaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EDIT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: DhanWiserColors.textSecondaryDark,
                              letterSpacing: 0.5,
                            ),
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
                            decoration: const BoxDecoration(
                              color: DhanWiserColors.negative,
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
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: DhanWiserColors.negative,
                              letterSpacing: 0.5,
                            ),
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
                  color: DhanWiserColors.backgroundDark,
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
