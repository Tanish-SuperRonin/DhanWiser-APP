import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'dart:ui' as ui;

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.background,
      body: Stack(
        children: [
          // Ambient Glow Top Left
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox(),
              ),
            ),
          ),
          // Ambient Glow Center Right
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DhanWiserColors.secondary.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox(),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Logo Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: DhanWiserColors.onPrimaryFixed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'DhanWiser',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: DhanWiserColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Abstract Graphic
                Expanded(
                  child: Center(
                    child: Transform.rotate(
                      angle: 12 * 3.1415927 / 180, // 12 degrees
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop',
                          width: MediaQuery.of(context).size.width * 0.65,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: MediaQuery.of(context).size.height * 0.4,
                              color: DhanWiserColors.surfaceContainer,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Card
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
                  decoration: const BoxDecoration(
                    color: DhanWiserColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: DhanWiserColors.textPrimary,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                            children: const [
                              TextSpan(text: 'Group\nSpending,\n'),
                              TextSpan(
                                text: 'Simplified.',
                                style: TextStyle(color: DhanWiserColors.primaryFixed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Track expenses, split bills, and settle up with friends without the awkward conversations.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: DhanWiserColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              onPressed: () => _completeOnboarding(context),
                              child: const Text('Get Started'),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => _completeOnboarding(context),
                              child: const Text('Log In'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
