import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'friend_discovery_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _onNavigateTab(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/add-expense');
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabIndexMap = _selectedIndex == 2
        ? 0
        : (_selectedIndex > 2 ? _selectedIndex - 1 : _selectedIndex);

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tabIndexMap,
          children: [
            HomeScreen(onNavigateTab: _onNavigateTab),
            const FriendDiscoveryScreen(isRootTab: true),
            const ActivityScreen(isRootTab: true),
            const ProfileScreen(isRootTab: true),
          ],
        ),
      ),
      // Floating Glass NavigationBar (Matching Airbnb UX Standards)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: NavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                height: 68,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onNavigateTab,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_filled),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.group_outlined),
                    selectedIcon: Icon(Icons.group),
                    label: 'Groups',
                  ),
                  NavigationDestination(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.of(context).primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: DhanWiserColors.of(context).onPrimaryFixed),
                    ),
                    label: 'Add',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Activity',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
