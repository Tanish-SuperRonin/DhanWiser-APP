import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/shimmer_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../providers/notification_provider.dart';
import '../services/expense_service.dart';
import '../services/cache_service.dart';
import '../models/balance_model.dart';
import '../models/server_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _loadingBalanceSummary = true;
  double _netBalance = 0;
  double _youOwe = 0;
  double _owedToYou = 0;

  // Debounce refresh
  DateTime? _lastRefreshTime;
  static const Duration _refreshDebounce = Duration(seconds: 3);

  // Cache keys
  static const String _balanceSummaryKey = 'home_balance_summary';
  static const Duration _balanceTtl = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _navigateAndRefresh(String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments)
        .then((_) => _loadData());
  }

  Future<void> _loadData() async {
    // Debounce: prevent rapid pull-to-refresh spam
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!) < _refreshDebounce) {
      return;
    }
    _lastRefreshTime = now;

    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Load cached balance summary immediately
      _loadCachedBalanceSummary();

      final futures = <Future>[
        serverProvider.fetchServers(),
        notifProvider.fetchUnreadCount(),
      ];

      if (authProvider.currentUser == null) {
        futures.add(authProvider.initialize());
      }

      await Future.wait(futures);
      await _loadBalanceSummary(serverProvider.servers, authProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _netBalance = 0;
        _youOwe = 0;
        _owedToYou = 0;
        _loadingBalanceSummary = false;
      });
    }
  }

  /// Load cached balance summary for instant display.
  void _loadCachedBalanceSummary() {
    final cached = CacheService.get<Map<String, double>>(_balanceSummaryKey);
    if (cached != null && mounted) {
      setState(() {
        _netBalance = cached['netBalance'] ?? 0;
        _youOwe = cached['youOwe'] ?? 0;
        _owedToYou = cached['owedToYou'] ?? 0;
        _loadingBalanceSummary = false;
      });
    }
  }

  Future<void> _loadBalanceSummary(
      List<ServerModel> servers, AuthProvider authProvider) async {
    if (!mounted) return;

    // Only show loading spinner if we have no cached data
    if (!CacheService.has(_balanceSummaryKey)) {
      setState(() {
        _loadingBalanceSummary = true;
      });
    }

    final currentUser = authProvider.currentUser;
    if (currentUser == null || servers.isEmpty) {
      if (!mounted) return;
      final summary = {'netBalance': 0.0, 'youOwe': 0.0, 'owedToYou': 0.0};
      CacheService.put(_balanceSummaryKey, summary, ttl: _balanceTtl);
      setState(() {
        _netBalance = 0;
        _youOwe = 0;
        _owedToYou = 0;
        _loadingBalanceSummary = false;
      });
      return;
    }

    double netBalance = 0;
    double oweTotal = 0;
    double owedTotal = 0;

    // Fetch all balances in parallel instead of sequential loop
    final futures = servers.map((server) async {
      try {
        final balanceData = await ExpenseService.getServerBalances(server.id);
        return balanceData;
      } catch (_) {
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);

    for (final balanceData in results) {
      if (balanceData == null) continue;

      final balances = balanceData['balances'] as List<BalanceModel>;

      BalanceModel? userBalance;
      for (final balance in balances) {
        if (balance.userId == currentUser.id) {
          userBalance = balance;
          break;
        }
      }

      if (userBalance == null) continue;

      netBalance += userBalance.balance;
      if (userBalance.balance < -0.01) {
        oweTotal += userBalance.balance.abs();
      } else if (userBalance.balance > 0.01) {
        owedTotal += userBalance.balance;
      }
    }

    // Cache the computed summary
    final summary = {
      'netBalance': netBalance,
      'youOwe': oweTotal,
      'owedToYou': owedTotal,
    };
    CacheService.put(_balanceSummaryKey, summary, ttl: _balanceTtl);

    if (!mounted) return;
    setState(() {
      _netBalance = netBalance;
      _youOwe = oweTotal;
      _owedToYou = owedTotal;
      _loadingBalanceSummary = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            // Force invalidate caches on manual pull-to-refresh
            _lastRefreshTime = null;
            await CacheService.invalidate(_balanceSummaryKey);
            await CacheService.invalidate('servers_list');
            await _loadData();
          },
          color: cs.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(cs),
                  const SizedBox(height: 24),
                  _buildBalanceCard(cs, isDark),
                  const SizedBox(height: 24),
                  _buildQuickActionsGrid(cs, isDark),
                  const SizedBox(height: 24),
                  _buildGroupsSection(cs, isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),

      // M3 Extended FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh('/add-expense'),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(
          'Split',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Floating Glass NavigationBar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? cs.surfaceContainerLowest.withValues(alpha: 0.65)
                    : cs.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: NavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                height: 68,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
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
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'HOME',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'EXPLORE',
                  ),
                  NavigationDestination(
                    icon: SizedBox(width: 24),
                    label: '',
                    enabled: false,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.show_chart_rounded),
                    selectedIcon: Icon(Icons.show_chart_rounded),
                    label: 'ACTIVITY',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'ME',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
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
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            // M3 Icon Button with badge
            Consumer<NotificationProvider>(
              builder: (context, notif, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/activity'),
                      icon: const Icon(
                          Icons.notifications_outlined, size: 22),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primaryContainer.withValues(alpha: 0.4),
                        foregroundColor: cs.primary,
                      ),
                    ),
                    if (notif.unreadCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 4),
            // M3 Profile avatar
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final initial =
                    (auth.currentUser?.fullName ?? 'U')[0].toUpperCase();
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.plusJakartaSans(
                          color: cs.onPrimaryContainer,
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

  Widget _buildBalanceCard(ColorScheme cs, bool isDark) {
    final balanceColor = _netBalance < -0.01
        ? DhanWiserColors.coral
        : _netBalance > 0.01
            ? DhanWiserColors.teal
            : cs.onSurface;

    return Card(
      elevation: 1,
      color: isDark
          ? cs.surfaceContainerHigh
          : cs.surfaceContainerLow,
      surfaceTintColor: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Net Balance',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _loadingBalanceSummary
                ? const ShimmerBox(width: 200, height: 46, borderRadius: 12)
                : Text(
                    _formatCurrency(_netBalance, withDecimals: true),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: balanceColor,
                      letterSpacing: -1.5,
                    ),
                  ),
            const SizedBox(height: 24),
            Divider(color: cs.outlineVariant, height: 1),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    'You owe',
                    _formatCurrency(_youOwe, withDecimals: true),
                    DhanWiserColors.coral,
                    Icons.arrow_upward_rounded,
                    cs,
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: cs.outlineVariant,
                ),
                Expanded(
                  child: _buildBalanceItem(
                    'Owed to you',
                    _formatCurrency(_owedToYou, withDecimals: true),
                    DhanWiserColors.teal,
                    Icons.arrow_downward_rounded,
                    cs,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic, duration: 300.ms);
  }

  Widget _buildBalanceItem(
      String label, String amount, Color color, IconData icon, ColorScheme cs) {
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
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

  Widget _buildQuickActionsGrid(ColorScheme cs, bool isDark) {
    final actions = [
      _QuickAction('New Group', Icons.group_add_rounded,
          DhanWiserColors.primary, '/create-server'),
      _QuickAction('Find Friends', Icons.person_search_rounded,
          DhanWiserColors.teal, '/friend-discovery'),
      _QuickAction('Settle Up', Icons.handshake_rounded,
          DhanWiserColors.warning, '/settlement'),
      _QuickAction('Settings', Icons.tune_rounded,
          cs.onSurfaceVariant, '/settings'),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateAndRefresh(action.route),
            child: Column(
              children: [
                // M3 tonal icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(action.icon, color: action.color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupsSection(ColorScheme cs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Groups',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            // M3 tonal button
            FilledButton.tonal(
              onPressed: () => _navigateAndRefresh('/create-server'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '+ New',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<ServerProvider>(
          builder: (context, serverProv, _) {
            if (serverProv.isLoading) {
              return _buildShimmerCards(cs, isDark);
            }

            if (serverProv.servers.isEmpty) {
              return _buildEmptyGroups(cs, isDark);
            }

            return Column(
              children: serverProv.servers.asMap().entries.map((entry) {
                final index = entry.key;
                final server = entry.value;
                return _buildGroupCard(
                  context,
                  cs,
                  isDark,
                  server.id,
                  server.name,
                  '${server.memberCount} members',
                  server.role == 'admin',
                ).animate().fade(duration: 200.ms, delay: (index * 50).ms)
                 .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic, duration: 200.ms);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupCard(BuildContext context, ColorScheme cs, bool isDark,
      int id, String name, String members, bool isAdmin) {
    final groupIcons = [
      Icons.home_rounded,
      Icons.flight_rounded,
      Icons.restaurant_rounded,
      Icons.work_rounded,
      Icons.sports_esports_rounded,
      Icons.shopping_cart_rounded,
      Icons.celebration_rounded,
      Icons.coffee_rounded
    ];
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BouncingButton(
        onTap: () => _navigateAndRefresh('/server-detail', arguments: {
          'serverId': id,
          'serverName': name,
          'members': members,
          'imageUrl': '',
        }),
        child: Card(
          elevation: 0,
          color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Hero(
                  tag: 'server_avatar_$id',
                  child: Container(
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
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Admin',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onPrimaryContainer,
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
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyGroups(ColorScheme cs, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 32,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a group and start splitting expenses\nwith friends and flatmates',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _navigateAndRefresh('/create-server'),
              child: const Text('Create Your First Group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCards(ColorScheme cs, bool isDark) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 84,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
        );
      }),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatCurrency(double value, {bool withDecimals = false}) {
    final normalized = value.abs() < 0.01 ? 0.0 : value;
    final number = withDecimals
        ? normalized.toStringAsFixed(2)
        : normalized.toStringAsFixed(0);
    return '₹$number';
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}
