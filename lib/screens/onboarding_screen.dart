import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onOnboardingComplete;

  const OnboardingScreen({
    Key? key,
    this.onOnboardingComplete,
  }) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Track Together,\nSettle Separately',
      'description': 'Join thousands of groups who manage trips, dinners, and rent with zero stress.',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCQqF3vXy9iYwY3Ns9Tilre2dwFIp8lyk7nPcisMA4Q0NrwDbfPFMDdrOyhqIKHpYqQAcEb91HCV-6OHuj9skGnLPwdCc0psUvimtar7Mef8SmUDHItzLVsVJa3MhxFj3YJusszIfiuXuJioUz66n6lmVhrcBambUz6XF16I_NYgrtgXUYZohlqD7DgGst1cQ7vJXaEQhUnwOt24fjfz2DSjpowrlANf_cMt7aU2M_f_2DTW8KZU4n-LhPKoWaIFi0DcpLM_Dn-HK3G',
      'floatingIcon': Icons.receipt_long,
    },
    {
      'title': 'Create Financial\nServers',
      'description': 'Organize expenses into Discord-like servers for different groups and events.',
      'imageUrl': 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Placeholder
      'floatingIcon': Icons.groups,
    },
    {
      'title': 'Control Your\nPrivacy',
      'description': 'Share UPI IDs only with trusted friends. Your financial details stay private.',
      'imageUrl': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Placeholder
      'floatingIcon': Icons.lock,
    },
  ];

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      
      final onComplete = widget.onOnboardingComplete;
      if (onComplete != null) {
        onComplete();
      } else {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final textColor = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final subTextColor = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation / Skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? Colors.white.withOpacity(0.1) : DhanWiserColors.gray200,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: isDark ? DhanWiserColors.gray400 : DhanWiserColors.gray500,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hero Illustration
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Decorative blob
                                Container(
                                  width: 256,
                                  height: 256,
                                  decoration: BoxDecoration(
                                    color: DhanWiserColors.primary.withOpacity(isDark ? 0.1 : 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  ),
                                
                                // Main Image
                                Container(
                                  width: 320,
                                  height: 320,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: isDark ? DhanWiserColors.surfaceDark.withOpacity(0.5) : DhanWiserColors.surfaceLight,
                                    border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.05) : DhanWiserColors.gray100,
                                    ),
                                    boxShadow: [
                                       BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          page['imageUrl'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Icon(page['floatingIcon'], size: 64, color: DhanWiserColors.primary),
                                          ),
                                        ),
                                        // Floating Icon Overlay
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isDark ? DhanWiserColors.surfaceDark.withOpacity(0.9) : DhanWiserColors.surfaceLight.withOpacity(0.9),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray100,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              page['floatingIcon'],
                                              color: DhanWiserColors.primary,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            
                            // Typography
                            Text(
                              page['title'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 28, // 32 on sm
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page['description'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: subTextColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Page Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: DhanWiserColors.primary,
                      dotColor: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray300,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 4,
                    ),
                  ),
                ),

                // Bottom Action Area
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64), // h-16 = 64px roughly
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // rounded-xl
                      ),
                      elevation: 8,
                      shadowColor: DhanWiserColors.primary.withOpacity(0.25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                         Icon(
                          Icons.arrow_forward,
                          size: 24,
                        ),
                      ],
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
}
