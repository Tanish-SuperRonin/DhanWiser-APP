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
          color: DhanWiserColors.primaryFixed,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(cs),
                  const SizedBox(height: 32),
                  _buildBalanceCard(cs, isDark),
                  const SizedBox(height: 32),
                  _buildQuickActionsGrid(cs, isDark),
                  const SizedBox(height: 32),
                  _buildGroupsSection(cs, isDark),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),

      // Floating Glass NavigationBar (Matching Tailwind)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: DhanWiserColors.surface.withValues(alpha: 0.8),
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
                onDestinationSelected: (index) {
                  if (index == 2) {
                    _navigateAndRefresh('/add-expense');
                  } else if (index == 1) {
                    Navigator.pushNamed(context, '/friend-discovery');
                  } else if (index == 3) {
                    Navigator.pushNamed(context, '/activity');
                  } else if (index == 4) {
                    Navigator.pushNamed(context, '/profile');
                  } else {
                    setState(() => _selectedIndex = index);
                  }
                },
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_filled),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    icon: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: DhanWiserColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: DhanWiserColors.onPrimaryFixed,
                        size: 28,
                      ),
                    ),
                    label: '',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications_rounded),
                    label: 'Activity',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
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

  Widget _buildHeader(ColorScheme cs) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.fullName ?? 'there';
        final initial =
            (auth.currentUser?.fullName ?? 'U').isNotEmpty ? (auth.currentUser?.fullName ?? 'U')[0].toUpperCase() : 'U';
            
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile avatar left
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: DhanWiserColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      color: DhanWiserColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            
            // Greeting center
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: DhanWiserColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.split(' ')[0],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: DhanWiserColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            
            // Notification bell right
            Consumer<NotificationProvider>(
              builder: (context, notif, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DhanWiserColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: DhanWiserColors.outlineVariant),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/activity'),
                        icon: const Icon(
                            Icons.notifications_outlined, size: 20),
                        color: DhanWiserColors.textPrimary,
                      ),
                    ),
                    if (notif.unreadCount > 0)
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: DhanWiserColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
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
        ? DhanWiserColors.error
        : _netBalance > 0.01
            ? DhanWiserColors.primaryFixed
            : DhanWiserColors.textPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: DhanWiserColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: DhanWiserColors.primaryFixed.withValues(alpha: 0.05),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          )
        ]
      ),
      child: Column(
        children: [
          Text(
            'Total Net Balance',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: DhanWiserColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _loadingBalanceSummary
              ? const ShimmerBox(width: 200, height: 56, borderRadius: 12)
              : Text(
                  _formatCurrency(_netBalance, withDecimals: true),
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: balanceColor,
                    letterSpacing: -1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'You Owe',
                  _formatCurrency(_youOwe, withDecimals: true),
                  DhanWiserColors.error,
                  Icons.arrow_upward_rounded,
                  cs,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: DhanWiserColors.outlineVariant,
              ),
              Expanded(
                child: _buildBalanceItem(
                  'Owed to You',
                  _formatCurrency(_owedToYou, withDecimals: true),
                  DhanWiserColors.primaryFixed,
                  Icons.arrow_downward_rounded,
                  cs,
                ),
              ),
            ],
          ),
        ],
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
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: DhanWiserColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(ColorScheme cs, bool isDark) {
    final actions = [
      _QuickAction('Create', Icons.group_add_rounded,
          DhanWiserColors.primaryFixed, '/create-server'),
      _QuickAction('Expense', Icons.receipt_long_rounded,
          DhanWiserColors.secondary, '/add-expense'),
      _QuickAction('Settle', Icons.handshake_rounded,
          DhanWiserColors.tertiaryFixed, '/settlement'),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateAndRefresh(action.route),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: DhanWiserColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DhanWiserColors.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, color: action.color, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DhanWiserColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: () {}, // Optional see all logic
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DhanWiserColors.primaryFixed,
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

    final idx = name.hashCode.abs();
    final groupIcon = groupIcons[idx % groupIcons.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BouncingButton(
        onTap: () => _navigateAndRefresh('/server-detail', arguments: {
          'serverId': id,
          'serverName': name,
          'members': members,
          'imageUrl': '',
        }),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DhanWiserColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DhanWiserColors.outlineVariant),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'server_avatar_$id',
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DhanWiserColors.primaryFixed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(groupIcon, color: DhanWiserColors.primaryFixed, size: 24),
                ),
              ),
              const SizedBox(width: 16),
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
                              color: DhanWiserColors.textPrimary,
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
                              color: DhanWiserColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: DhanWiserColors.secondary,
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
                        fontSize: 14,
                        color: DhanWiserColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: DhanWiserColors.textDisabled,
                size: 24,
              ),
            ],
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
