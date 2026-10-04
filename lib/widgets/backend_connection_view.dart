import '../theme/text_styles.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/iconly_icons.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class BackendConnectionView extends StatefulWidget {
  final Future<void> Function()? onRetry;
  final String title;
  
  const BackendConnectionView({
    super.key, 
    this.onRetry,
    this.title = 'Connecting...',
  });

  @override
  State<BackendConnectionView> createState() => _BackendConnectionViewState();
}

class _BackendConnectionViewState extends State<BackendConnectionView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _showRetry = false;
  Timer? _escalationTimer;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startEscalationTimer();
  }

  void _startEscalationTimer() {
    _escalationTimer?.cancel();
    setState(() {
      _showRetry = false;
      _isRetrying = false;
    });
    
    _escalationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showRetry = true;
        });
      }
    });
  }

  Future<void> _handleRetry() async {
    if (widget.onRetry == null) return;
    
    setState(() {
      _isRetrying = true;
    });
    
    try {
      await widget.onRetry!();
    } finally {
      if (mounted) {
        _startEscalationTimer();
      }
    }
  }

  @override
  void dispose() {
    _escalationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // M3 branded icon with surface tint
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  IconlyBold.wallet,
                  color: cs.onPrimaryContainer,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'DhanWiser',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            if (!_showRetry || _isRetrying)
              Column(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: cs.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: DhanWiserTextStyles.caption(context).copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    'Still connecting... this might take up to a minute if the backend is waking up.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.onRetry != null)
                    PremiumElevatedButton(
                      onPressed: _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Retry Connection'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
