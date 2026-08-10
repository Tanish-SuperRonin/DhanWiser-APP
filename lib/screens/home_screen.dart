import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/dhanwiser_ui.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../providers/notification_provider.dart';
import '../services/expense_service.dart';
import '../services/cache_service.dart';
import '../models/balance_model.dart';
import '../models/server_model.dart';
import '../theme/design_tokens.dart';
import 'friend_discovery_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
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

    final homeContent = RefreshIndicator(
      onRefresh: () async {
        // Force invalidate caches on manual pull-to-refresh
        _lastRefreshTime = null;
        await CacheService.invalidate(_balanceSummaryKey);
        await CacheService.invalidate('servers_list');
        await _loadData();
      },
      color: DhanWiserColors.of(context).primaryFixed,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: DhanWiserTokens.pagePadding,
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
    );

    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      body: homeContent,
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.fullName ?? 'there';
        final initial = (auth.currentUser?.fullName ?? 'U').isNotEmpty
            ? (auth.currentUser?.fullName ?? 'U')[0].toUpperCase()
            : 'U';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile avatar left
            GestureDetector(
              onTap: () => widget.onNavigateTab(4),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DhanWiserColors.of(context).surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: DhanWiserColors.of(context).textPrimary,
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
                  style: DhanWiserTextStyles.overline(context)
                      .copyWith(color: DhanWiserColors.of(context).textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  name.split(' ')[0],
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
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
                        color: DhanWiserColors.of(context).surface,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: DhanWiserColors.of(context).outlineVariant),
                      ),
                      child: PremiumIconButton(
                        onPressed: () =>
                            widget.onNavigateTab(3),
                        icon:
                            const Icon(Icons.notifications_outlined, size: 20),
                        color: DhanWiserColors.of(context).textPrimary,
                      ),
                    ),
                    if (notif.unreadCount > 0)
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: DhanWiserColors.of(context).primaryFixed,
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
    final netColor = _netBalance < -0.01
        ? DhanWiserColors.of(context).error
        : _netBalance > 0.01
            ? DhanWiserColors.of(context).tertiary
            : DhanWiserColors.of(context).textPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DhanWiserColors.of(context).surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: DhanWiserColors.of(context).outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NET BALANCE',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    letterSpacing: 1.0, color: DhanWiserColors.of(context).textSecondary),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: netColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _netBalance < -0.01
                      ? 'You Owe'
                      : _netBalance > 0.01
                          ? 'You Get Back'
                          : 'Settled',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: netColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _loadingBalanceSummary
              ? const ShimmerBox(width: 200, height: 48, borderRadius: 12)
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatCurrency(_netBalance, withDecimals: true),
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: netColor, letterSpacing: -1.0),
                  ),
                ),
          const SizedBox(height: 20),
          Divider(
              color: DhanWiserColors.of(context).outlineVariant.withValues(alpha: 0.3),
              height: 1),
          const SizedBox(height: 16),

          // Detailed Owed / Owe split pills
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_downward_rounded,
                            size: 14, color: DhanWiserColors.of(context).tertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Owed to you',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: DhanWiserColors.of(context).textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_owedToYou),
                      style: DhanWiserTextStyles.buttonLarge(context)
                          .copyWith(color: DhanWiserColors.of(context).tertiary),
                    ),
                  ],
                ),
              ),
              Container(
                  width: 1,
                  height: 36,
                  color: DhanWiserColors.of(context).outlineVariant.withValues(alpha: 0.3)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded,
                            size: 14, color: DhanWiserColors.of(context).error),
                        const SizedBox(width: 4),
                        Text(
                          'You owe',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: DhanWiserColors.of(context).textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(_youOwe),
                      style: DhanWiserTextStyles.buttonLarge(context)
                          .copyWith(color: DhanWiserColors.of(context).error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(
        begin: 0.1, end: 0, curve: Curves.easeOutCubic, duration: 300.ms);
  }

  Widget _buildQuickActionsGrid(ColorScheme cs, bool isDark) {
    final actions = [
      _QuickAction('Create', Icons.group_add_rounded,
          DhanWiserColors.of(context).primaryFixed, '/create-server'),
      _QuickAction('Expense', Icons.receipt_long_rounded,
          DhanWiserColors.of(context).secondary, '/add-expense'),
      _QuickAction('Settle', Icons.handshake_rounded,
          DhanWiserColors.of(context).tertiaryFixed, '/settlement'),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: DhanWiserSurface(
            onTap: () => _navigateAndRefresh(action.route),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: action.color, size: 28),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: DhanWiserTextStyles.overline(context)
                      .copyWith(color: DhanWiserColors.of(context).textPrimary),
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
        const DhanWiserSectionHeader(title: 'Your groups'),
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
                )
                    .animate()
                    .fade(duration: 200.ms, delay: (index * 50).ms)
                    .slideX(
                        begin: 0.05,
                        end: 0,
                        curve: Curves.easeOutCubic,
                        duration: 200.ms);
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
      child: DhanWiserSurface(
        onTap: () => _navigateAndRefresh('/server-detail', arguments: {
          'serverId': id,
          'serverName': name,
          'members': members,
          'imageUrl': '',
        }),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Hero(
              tag: 'server_avatar_$id',
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: DhanWiserColors.of(context).primaryFixed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(groupIcon,
                    color: DhanWiserColors.of(context).primaryFixed, size: 24),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: DhanWiserColors.of(context).textPrimary),
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
                            color: DhanWiserColors.of(context).secondary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Admin',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: DhanWiserColors.of(context).secondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    members,
                    style: DhanWiserTextStyles.caption(context)
                        .copyWith(color: DhanWiserColors.of(context).textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: DhanWiserColors.of(context).textDisabled,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGroups(ColorScheme cs, bool isDark) {
    return DhanWiserSurface(
      tint: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      radius: DhanWiserTokens.radiusLarge,
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
            style: DhanWiserTextStyles.buttonLarge(context)
                .copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a group and start splitting expenses\nwith friends and flatmates',
            textAlign: TextAlign.center,
            style: DhanWiserTextStyles.caption(context)
                .copyWith(color: cs.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 20),
          PremiumFilledButton(
            onPressed: () => _navigateAndRefresh('/create-server'),
            child: const Text('Create Your First Group'),
          ),
        ],
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
