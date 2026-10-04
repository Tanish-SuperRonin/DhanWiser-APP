import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/iconly_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/streak_service.dart';
import '../widgets/daily_streak_card.dart';
import '../widgets/dhanwiser_ui.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/dhanwiser_charts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../providers/notification_provider.dart';
import '../services/expense_service.dart';
import '../services/cache_service.dart';
import '../models/balance_model.dart';
import '../models/expense_model.dart';
import '../models/paginated_response.dart';
import '../models/server_model.dart';
import '../theme/design_tokens.dart';
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
  List<ExpenseModel> _expenses = [];
  bool _loadingExpenses = true;

  // Analytics chart state
  int _activeAnalyticsTab = 0; // 0: Trend, 1: Category Breakdown
  int _chartPeriodIndex = 0; // 0: 7D, 1: 30D, 2: 90D
  DailyStreakInfo? _streakInfo;

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
      await Future.wait([
        _loadBalanceSummary(serverProvider.servers, authProvider),
        _loadExpenseSummary(serverProvider.servers),
      ]);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _netBalance = 0;
        _youOwe = 0;
        _owedToYou = 0;
        _loadingBalanceSummary = false;
        _loadingExpenses = false;
      });
    }
  }

  Future<void> _loadExpenseSummary(List<ServerModel> servers) async {
    if (servers.isEmpty) {
      if (mounted) {
        setState(() {
          _expenses = [];
          _loadingExpenses = false;
        });
      }
      return;
    }

    final pages = await Future.wait(servers.map((server) async {
      try {
        return await ExpenseService.getServerExpenses(server.id, limit: 100);
      } catch (_) {
        return null;
      }
    }));
    final latest = pages
        .whereType<PaginatedResponse<ExpenseModel>>()
        .expand((page) => page.items)
        .toList()
      ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    if (!mounted) return;
    setState(() {
      _expenses = latest;
      _loadingExpenses = false;
    });

    StreakService.recordDailyCheckIn(youOwe: _youOwe, owedToYou: _owedToYou).then((info) {
      if (mounted) setState(() => _streakInfo = info);
    });
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

    StreakService.recordDailyCheckIn(youOwe: oweTotal, owedToYou: owedTotal).then((info) {
      if (mounted) setState(() => _streakInfo = info);
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
              const SizedBox(height: 24),
              HeroBalanceCard(
                netBalance: _netBalance,
                owedToYou: _owedToYou,
                youOwe: _youOwe,
                isLoading: _loadingBalanceSummary,
                onSettleTap: () => _navigateAndRefresh('/settlement'),
                onAddExpenseTap: () => _navigateAndRefresh('/add-expense'),
              )
                  .animate()
                  .fade(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              if (_owedToYou > 0.01 || _youOwe > 0.01) ...[
                const SizedBox(height: 14),
                BalanceRatioBar(
                  owedToYou: _owedToYou,
                  youOwe: _youOwe,
                ).animate().fade(duration: 350.ms),
              ],
              const SizedBox(height: 16),
              DailyStreakCard(
                streakInfo: _streakInfo,
                onActionTap: () {
                  if (_youOwe > 0.01 || _owedToYou > 0.01) {
                    _navigateAndRefresh('/settlement');
                  } else {
                    _navigateAndRefresh('/friend-discovery');
                  }
                },
              ).animate().fade(duration: 350.ms).slideY(begin: 0.04, end: 0),
              const SizedBox(height: 24),
              _buildQuickActionsGrid(cs, isDark),
              const SizedBox(height: 32),
              _buildAnalyticsSection(cs, isDark),
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
        final firstName = name.split(' ').first;

        final colors = DhanWiserColors.of(context);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, notif, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: IconButton(
                      tooltip: 'Activity and notifications',
                      onPressed: () => widget.onNavigateTab(2),
                      icon: Icon(
                          notif.unreadCount > 0
                              ? IconlyBold.notification
                              : IconlyLight.notification,
                          size: 21,
                          color: colors.textPrimary),
                    ),
                  ),
                  if (notif.unreadCount > 0)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.primaryFixed,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: 'Go to Profile',
              button: true,
              child: GestureDetector(
                onTap: () => widget.onNavigateTab(3),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryFixed.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.primaryFixed.withValues(alpha: 0.35),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(ColorScheme cs, bool isDark) {
    final colors = DhanWiserColors.of(context);
    final actions = [
      _QuickAction('Find Friends', IconlyBold.addUser, colors.primaryFixed,
          '/friend-discovery'),
      _QuickAction('New Group', IconlyBold.user2, colors.secondary,
          '/create-server'),
      _QuickAction('Expense', Icons.add_rounded, colors.emerald,
          '/add-expense'),
      _QuickAction(
          'Settle Up', IconlyBold.swap, colors.tertiary, '/settlement'),
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Semantics(
              label: '${action.label} quick action',
              button: true,
              child: DhanWiserSurface(
                onTap: () => _navigateAndRefresh(action.route),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                radius: DhanWiserTokens.radiusMedium,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(action.icon, color: action.color, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      action.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsSection(ColorScheme cs, bool isDark) {
    final colors = DhanWiserColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INSIGHTS & TRENDS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: colors.textSecondary,
              ),
            ),
            // Segmented pill control
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  _buildTabOption(0, 'Trends', colors),
                  _buildTabOption(1, 'Categories', colors),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _loadingExpenses
              ? _buildInsightsLoading(colors)
              : _expenses.isEmpty
                  ? _buildInsightsEmpty(colors)
                  : _activeAnalyticsTab == 0
                      ? _buildSpendingTrend()
                      : _buildCategoryBreakdown(),
        ),
      ],
    );
  }

  Widget _buildSpendingTrend() {
    final days = [7, 30, 90][_chartPeriodIndex];
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final start = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final inRange = _expenses
        .where((expense) =>
            !expense.expenseDate.isBefore(start) &&
            !expense.expenseDate.isAfter(end))
        .toList();
    const bucketCount = 7;
    final spots = <FlSpot>[];
    final labels = <String>[];
    for (var i = 0; i < bucketCount; i++) {
      final from = start.add(Duration(days: (days * i / bucketCount).floor()));
      final to = i == bucketCount - 1
          ? end.add(const Duration(seconds: 1))
          : start.add(Duration(days: (days * (i + 1) / bucketCount).floor()));
      final amount = inRange
          .where((expense) =>
              !expense.expenseDate.isBefore(from) &&
              expense.expenseDate.isBefore(to))
          .fold<double>(0, (sum, expense) => sum + expense.totalAmount);
      spots.add(FlSpot(i.toDouble(), amount));
      final date = from;
      labels.add(days == 7
          ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1]
          : '${date.day}/${date.month}');
    }
    final total =
        inRange.fold<double>(0, (sum, expense) => sum + expense.totalAmount);

    return SpendingTrendChart(
      key: const ValueKey('trend_chart'),
      spots: spots,
      xLabels: labels,
      totalAmount: total,
      periodLabel: 'Last $days days',
      percentageChange: null,
      selectedPeriodIndex: _chartPeriodIndex,
      onPeriodChanged: (idx) => setState(() => _chartPeriodIndex = idx),
    );
  }

  Widget _buildCategoryBreakdown() {
    final from = DateTime.now().subtract(const Duration(days: 90));
    final amounts = <String, double>{};
    for (final expense in _expenses) {
      if (expense.expenseDate.isBefore(from)) continue;
      final category = expense.category?.trim().isNotEmpty == true
          ? expense.category!.trim()
          : 'Other';
      amounts[category] = (amounts[category] ?? 0) + expense.totalAmount;
    }
    final total = amounts.values.fold<double>(0, (sum, amount) => sum + amount);
    return CategoryDonutChart(
      key: const ValueKey('donut_chart'),
      categoryAmounts: amounts,
      totalAmount: total,
    );
  }

  Widget _buildInsightsLoading(DhanWiserColors colors) {
    return DhanWiserSurface(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 12, width: 130, color: colors.surfaceContainerHigh),
          const SizedBox(height: 16),
          Container(height: 118, color: colors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildInsightsEmpty(DhanWiserColors colors) {
    return DhanWiserSurface(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Icon(Icons.insights_outlined, color: colors.secondary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your spending story starts here',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                        )),
                const SizedBox(height: 4),
                Text('Add a shared expense to see real trends and categories.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption(int index, String title, DhanWiserColors colors) {
    final isSelected = _activeAnalyticsTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeAnalyticsTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? colors.surfaceContainerHighest
                  : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
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
    final colors = DhanWiserColors.of(context);
    final groupIcons = [
      Icons.home_rounded,
      Icons.flight_takeoff_rounded,
      Icons.restaurant_rounded,
      Icons.work_rounded,
      Icons.sports_esports_rounded,
      Icons.shopping_bag_rounded,
      Icons.celebration_rounded,
      Icons.coffee_rounded,
    ];

    final gradientPairs = [
      [colors.primaryFixed, colors.tertiary],
      [colors.secondary, colors.catFun],
      [colors.tertiary, colors.catTransport],
      [colors.catFood, colors.warning],
      [colors.catTransport, colors.secondary],
      [colors.catFun, colors.primaryFixed],
    ];

    final idx = name.hashCode.abs();
    final groupIcon = groupIcons[idx % groupIcons.length];
    final pair = gradientPairs[idx % gradientPairs.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DhanWiserSurface(
        onTap: () => _navigateAndRefresh('/server-detail', arguments: {
          'serverId': id,
          'serverName': name,
          'members': members,
          'imageUrl': '',
        }),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: DhanWiserTokens.radiusMedium,
        child: Row(
          children: [
            Hero(
              tag: 'server_avatar_$id',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      pair[0].withValues(alpha: 0.22),
                      pair[1].withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: pair[0].withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Icon(groupIcon, color: pair[0], size: 22),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'ADMIN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: colors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 13,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        members,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary,
                size: 18,
              ),
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
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _QuickAction(this.label, this.icon, this.color, this.route);
}
