import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await Future.wait([
      serverProvider.fetchServers(),
      notifProvider.fetchUnreadCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final surface = isDark ? DhanWiserColors.surfaceDark : DhanWiserColors.surfaceLight;
    final elevated = isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.surfaceElevatedLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: DhanWiserColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Header ──
                  _buildHeader(text, sub),
                  const SizedBox(height: 28),

                  // ── Balance Overview ──
                  _buildBalanceCard(isDark, surface),
                  const SizedBox(height: 28),

                  // ── Quick Actions Grid ──
                  _buildQuickActionsGrid(isDark, surface, text, sub),
                  const SizedBox(height: 28),

                  // ── Your Groups ──
                  _buildGroupsSection(isDark, surface, elevated, text, sub),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),

      // ── FAB ──
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DhanWiserColors.primary, DhanWiserColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DhanWiserColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add-expense'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: Text(
            'Split',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      // ── Bottom Nav ──
      bottomNavigationBar: _buildBottomNav(isDark, surface, sub),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HEADER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHeader(Color text, Color sub) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.fullName ?? 'there';
        final greeting = _getGreeting();
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: sub,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      color: text,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Notification bell
            Consumer<NotificationProvider>(
              builder: (context, notif, _) {
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/activity'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: DhanWiserColors.primary,
                          size: 24,
                        ),
                        if (notif.unreadCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: DhanWiserColors.coral,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: DhanWiserColors.backgroundDark,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // Profile avatar
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final initial = (auth.currentUser?.fullName ?? 'U')[0].toUpperCase();
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DhanWiserColors.primary, DhanWiserColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BALANCE CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBalanceCard(bool isDark, Color surface) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? DhanWiserColors.primary.withValues(alpha: 0.15)
              : DhanWiserColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : DhanWiserColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total balance header
          Text(
            'Net Balance',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Consumer<ServerProvider>(
            builder: (context, serverProv, _) {
              return Text(
                '₹0.00',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : DhanWiserColors.textPrimaryLight,
                  letterSpacing: -1.5,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Owe / Owed row
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'You owe',
                  '₹0',
                  DhanWiserColors.coral,
                  Icons.arrow_upward_rounded,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200,
              ),
              Expanded(
                child: _buildBalanceItem(
                  'Owed to you',
                  '₹0',
                  DhanWiserColors.teal,
                  Icons.arrow_downward_rounded,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
      String label, String amount, Color color, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // QUICK ACTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildQuickActionsGrid(bool isDark, Color surface, Color text, Color sub) {
    final actions = [
      _QuickAction('New Group', Icons.group_add_rounded, DhanWiserColors.primary, '/create-server'),
      _QuickAction('Find Friends', Icons.person_search_rounded, DhanWiserColors.teal, '/friend-discovery'),
      _QuickAction('Settle Up', Icons.handshake_rounded, DhanWiserColors.warning, '/settlement'),
      _QuickAction('Settings', Icons.tune_rounded, DhanWiserColors.gray400, '/settings'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, action.route),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(action.icon, color: action.color, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: sub,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // GROUPS SECTION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildGroupsSection(bool isDark, Color surface, Color elevated, Color text, Color sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Groups',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: text,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/create-server'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DhanWiserColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+ New',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DhanWiserColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Consumer<ServerProvider>(
          builder: (context, serverProv, _) {
            if (serverProv.isLoading) {
              return _buildShimmerCards(isDark);
            }

            if (serverProv.servers.isEmpty) {
              return _buildEmptyGroups(isDark, text, sub);
            }

            return Column(
              children: serverProv.servers.map((server) {
                return _buildGroupCard(
                  context, isDark, surface, text, sub,
                  server.id, server.name, '${server.memberCount} members',
                  server.role == 'admin',
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context, bool isDark, Color surface,
      Color text, Color sub, int id, String name, String members, bool isAdmin) {
    // Deterministic icon/color from name
    final groupIcons = [Icons.home_rounded, Icons.flight_rounded, Icons.restaurant_rounded, Icons.work_rounded, Icons.sports_esports_rounded, Icons.shopping_cart_rounded, Icons.celebration_rounded, Icons.coffee_rounded];
    final gradients = [
      [const Color(0xFFFFAD60), const Color(0xFFFFCF9D)],
      [const Color(0xFFB5EAD7), const Color(0xFFA8E6CF)],
      [const Color(0xFFFFB5A7), const Color(0xFFFFCDBD)],
      [const Color(0xFFFFD97D), const Color(0xFFFFE5A0)],
      [const Color(0xFF74B9FF), const Color(0xFFA3D5FF)],
    ];
    final idx = name.hashCode.abs();
    final groupIcon = groupIcons[idx % groupIcons.length];
    final grad = gradients[idx % gradients.length];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/server-detail', arguments: {
        'serverId': id,
        'serverName': name,
        'members': members,
        'imageUrl': '',
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: grad,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(groupIcon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: DhanWiserColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Admin',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: DhanWiserColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    members,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: sub,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: sub.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGroups(bool isDark, Color text, Color sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? DhanWiserColors.gray700.withValues(alpha: 0.5)
              : DhanWiserColors.gray200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DhanWiserColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 32,
              color: DhanWiserColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No groups yet',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a group and start splitting expenses\nwith friends and flatmates',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: sub,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/create-server'),
            style: TextButton.styleFrom(
              backgroundColor: DhanWiserColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Create Your First Group',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCards(bool isDark) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 84,
          decoration: BoxDecoration(
            color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BOTTOM NAV
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildBottomNav(bool isDark, Color surface, Color sub) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.search_rounded, Icons.search_rounded, 'Explore'),
              const SizedBox(width: 56), // space for FAB
              _buildNavItem(3, Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Activity'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Me'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, '/friend-discovery');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/activity');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/profile');
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? DhanWiserColors.primary : DhanWiserColors.gray400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? DhanWiserColors.primary : DhanWiserColors.gray400,
              ),
            ),
            const SizedBox(height: 2),
            // Active indicator pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: DhanWiserColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HELPERS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}