import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  final _pages = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Split expenses\neffortlessly',
      'subtitle':
          'No more awkward money conversations. Just add, split, and settle.',
    },
    {
      'icon': Icons.group_rounded,
      'title': 'Groups for\neverything',
      'subtitle':
          'Roommates, trips, dinners — create groups and track it all.',
    },
    {
      'icon': Icons.check_circle_rounded,
      'title': 'Settle up\ninstantly',
      'subtitle': 'See who owes what and close balances with a tap.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    // Show splash-style screen on first page
    if (_currentPage == 0) {
      return Scaffold(
        backgroundColor: DhanWiserColors.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // Skip at top right
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmSans(
                          color: DhanWiserColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Centered D₹ logo with rotating ring
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSplashPage();
                      }
                      return _buildOnboardingPage(_pages[index]);
                    },
                  ),
                ),

                // Dots indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: DhanWiserColors.primary,
                    dotColor: DhanWiserColors.outlineDark,
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: 32),

                // Get Started button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _completeOnboarding,
                    style: FilledButton.styleFrom(
                      backgroundColor: DhanWiserColors.primary,
                      foregroundColor: DhanWiserColors.backgroundDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Already have account
                GestureDetector(
                  onTap: _goToLogin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'I already have an account',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: DhanWiserColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: DhanWiserColors.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    // Subsequent onboarding pages
    return Scaffold(
      backgroundColor: DhanWiserColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.dmSans(
                        color: DhanWiserColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildSplashPage();
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: DhanWiserColors.primary,
                  dotColor: DhanWiserColors.outlineDark,
                  expansionFactor: 3,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: isLast
                      ? _completeOnboarding
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: DhanWiserColors.primary,
                    foregroundColor: DhanWiserColors.backgroundDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isLast ? 'Get Started' : 'Continue',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Splash-style first page with D₹ animated ring
  Widget _buildSplashPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated ring around D₹ logo
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating ring
              AnimatedBuilder(
                animation: _ringAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _ringAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DhanWiserColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 65,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: DhanWiserColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Center D₹ logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: DhanWiserColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DhanWiserColors.primary.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'D',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: DhanWiserColors.backgroundDark,
                          ),
                        ),
                        TextSpan(
                          text: '₹',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: DhanWiserColors.backgroundDark
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Brand name
        Text(
          'DhanWiser',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: DhanWiserColors.textPrimaryDark,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Split bills. Manage groups. Pay securely.',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: DhanWiserColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  /// Standard onboarding page
  Widget _buildOnboardingPage(Map<String, Object> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: DhanWiserColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: DhanWiserColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            page['icon'] as IconData,
            size: 44,
            color: DhanWiserColors.backgroundDark,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          page['title'] as String,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: DhanWiserColors.textPrimaryDark,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            page['subtitle'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: DhanWiserColors.textSecondaryDark,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
