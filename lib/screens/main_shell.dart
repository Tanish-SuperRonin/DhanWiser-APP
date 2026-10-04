import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dhanwiser_fixed/services/api_client.dart';

import '../theme/colors.dart';
import '../theme/iconly_icons.dart';
import 'home_screen.dart';
import 'groups_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ApiClient.startKeepAlive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ApiClient.startKeepAlive();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ApiClient.stopKeepAlive();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ApiClient.stopKeepAlive();
    super.dispose();
  }

  void _onNavigateTab(int index) {
    int target = index;
    // Legacy 5-tab fallback where 4 was Profile
    if (index == 4) {
      target = 3;
    }
    if (target >= 0 && target < 4) {
      setState(() => _selectedIndex = target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomMargin = bottomInset > 0 ? bottomInset + 6 : 20.0;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(onNavigateTab: _onNavigateTab),
            const GroupsScreen(),
            const ActivityScreen(isRootTab: true),
            const ProfileScreen(isRootTab: true),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomMargin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Modern Floating Capsule Dock ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainer.withValues(alpha: 0.92)
                            : colors.surfaceContainerLow.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isDark
                              ? colors.outlineVariant.withValues(alpha: 0.7)
                              : colors.outlineVariant.withValues(alpha: 0.85),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0x40000000)
                                : const Color(0x140F172A),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavItem(
                            index: 0,
                            selectedIcon: IconlyBold.home,
                            unselectedIcon: IconlyLight.home,
                            label: 'Home',
                            colors: colors,
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            index: 1,
                            selectedIcon: IconlyBold.user2,
                            unselectedIcon: IconlyLight.user2,
                            label: 'Groups',
                            colors: colors,
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            index: 2,
                            selectedIcon: IconlyBold.activity,
                            unselectedIcon: IconlyLight.activity,
                            label: 'Activity',
                            colors: colors,
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            index: 3,
                            selectedIcon: IconlyBold.profile,
                            unselectedIcon: IconlyLight.profile,
                            label: 'Profile',
                            colors: colors,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ── Standalone Circular Action Button (+) ──
                _buildCircularAddButton(context, colors, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required String label,
    required DhanWiserColors colors,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    final activeBg = isDark ? colors.surfaceBright : Colors.white;
    final activeFg = colors.primaryFixed;
    final inactiveFg = colors.textSecondary;

    return Semantics(
      label: '$label tab',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          _onNavigateTab(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          height: 46,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 15 : 13,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            border: isSelected
                ? Border.all(
                    color: isDark
                        ? colors.primaryFixed.withValues(alpha: 0.22)
                        : colors.outlineVariant.withValues(alpha: 0.8),
                    width: 0.8,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isDark
                          ? const Color(0x33000000)
                          : const Color(0x100F172A),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                size: 21,
                color: isSelected ? activeFg : inactiveFg,
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  child: isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 7),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: activeFg,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularAddButton(
    BuildContext context,
    DhanWiserColors colors,
    bool isDark,
  ) {
    return Semantics(
      label: 'Add expense',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(context, '/add-expense');
        },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.primaryFixed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.primaryFixed.withValues(alpha: isDark ? 0.38 : 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add_rounded,
            size: 30,
            color: colors.onPrimaryFixed,
          ),
        ),
      ),
    );
  }
}
