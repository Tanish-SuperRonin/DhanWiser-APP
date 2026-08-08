import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'dart:ui' as ui;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title1': 'Group\nSpending,\n',
      'title2': 'Simplified.',
      'subtitle': 'Track expenses, split bills, and settle up with friends without awkward conversations.',
      'image': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop',
      'icon': 'account_balance_wallet_rounded',
    },
    {
      'title1': 'Smart\nDebt\n',
      'title2': 'Minimization.',
      'subtitle': 'Our intelligent engine reduces multi-person transactions to fewer, simpler transfers.',
      'image': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=2564&auto=format&fit=crop',
      'icon': 'hub_rounded',
    },
    {
      'title1': 'Instant\nUPI\n',
      'title2': 'Settlements.',
      'subtitle': 'Approve payment proofs in real-time with zero hidden fees and direct verification.',
      'image': 'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=2564&auto=format&fit=crop',
      'icon': 'handshake_rounded',
    },
  ];

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    await prefs.setBool('onboarding_complete', true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: DhanWiserColors.primaryFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
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
                      TextButton(
                        onPressed: () => _completeOnboarding(context),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: DhanWiserColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Graphic PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final item = _slides[index];
                      return Center(
                        child: Transform.rotate(
                          angle: (index % 2 == 0 ? 8 : -8) * 3.1415927 / 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.network(
                              item['image']!,
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: MediaQuery.of(context).size.height * 0.35,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: MediaQuery.of(context).size.height * 0.35,
                                  decoration: BoxDecoration(
                                    color: DhanWiserColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        index == 0
                                            ? Icons.account_balance_wallet_rounded
                                            : index == 1
                                                ? Icons.hub_rounded
                                                : Icons.handshake_rounded,
                                        size: 64,
                                        color: DhanWiserColors.primaryFixed,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'DhanWiser',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          color: DhanWiserColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: MediaQuery.of(context).size.width * 0.65,
                                  height: MediaQuery.of(context).size.height * 0.35,
                                  color: DhanWiserColors.surfaceContainer,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Slide Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (idx) {
                    final isActive = idx == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? DhanWiserColors.primaryFixed : DhanWiserColors.outline,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Bottom Card
                Container(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                  decoration: BoxDecoration(
                    color: DhanWiserColors.surface,
                    borderRadius: const BorderRadius.only(
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
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: DhanWiserColors.textPrimary,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                            children: [
                              TextSpan(text: slide['title1']),
                              TextSpan(
                                text: slide['title2'],
                                style: TextStyle(color: DhanWiserColors.primaryFixed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['subtitle']!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: DhanWiserColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              onPressed: () {
                                if (_currentPage < _slides.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _completeOnboarding(context);
                                }
                              },
                              child: Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
                            ),
                            const SizedBox(height: 12),
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
