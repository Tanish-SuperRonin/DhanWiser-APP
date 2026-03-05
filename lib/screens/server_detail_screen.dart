import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import '../services/expense_service.dart';
import '../models/expense_model.dart';
import '../models/balance_model.dart';

class ServerDetailScreen extends StatefulWidget {
  final int serverId;
  final String serverName;
  final String members;
  final String imageUrl;

  const ServerDetailScreen({
    super.key,
    this.serverId = 0,
    this.serverName = 'Server',
    this.members = '0 members',
    this.imageUrl = '',
  });

  @override
  State<ServerDetailScreen> createState() => _ServerDetailScreenState();
}

class _ServerDetailScreenState extends State<ServerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ExpenseModel> _expenses = [];
  List<BalanceModel> _balances = [];
  List<SuggestedSettlement> _suggestions = [];
  bool _loadingExpenses = true;
  bool _loadingBalances = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final serverProvider = Provider.of<ServerProvider>(context, listen: false);
    await serverProvider.fetchServerDetails(widget.serverId);

    try {
      _expenses = await ExpenseService.getServerExpenses(widget.serverId);
    } catch (_) {}
    _loadingExpenses = false;

    try {
      final balanceData = await ExpenseService.getServerBalances(widget.serverId);
      _balances = balanceData['balances'] as List<BalanceModel>;
      _suggestions = balanceData['suggestedSettlements'] as List<SuggestedSettlement>;
    } catch (_) {}
    _loadingBalances = false;

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final surface = isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    // Deterministic gradient from server name
    final grads = [
      [const Color(0xFF4ECDC4), const Color(0xFF7EDDD6)],
      [const Color(0xFF95E1D3), const Color(0xFFA8E6CF)],
      [const Color(0xFFFFB5A7), const Color(0xFFFFCDBD)],
      [const Color(0xFFFFD97D), const Color(0xFFFFE5A0)],
    ];
    final grad = grads[widget.serverName.hashCode.abs() % grads.length];

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: bg,
              elevation: 0,
              pinned: true,
              expandedHeight: 200,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/add-expense',
                        arguments: {'serverId': widget.serverId}),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            'Expense',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Consumer<ServerProvider>(
                      builder: (context, serverProv, _) {
                        final detail = serverProv.currentServerDetail;
                        final name = detail?.server.name ?? widget.serverName;
                        final memberCount = detail?.members.length ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 56, right: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Server icon
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$memberCount members',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: DhanWiserColors.primary,
                    unselectedLabelColor: sub,
                    indicatorColor: DhanWiserColors.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Expenses'),
                      Tab(text: 'Balances'),
                      Tab(text: 'Members'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildExpensesTab(isDark, surface, text, sub),
            _buildBalancesTab(isDark, surface, text, sub),
            _buildMembersTab(isDark, surface, text, sub),
          ],
        ),
      ),
    );
  }

  // ── EXPENSES TAB ──
  Widget _buildExpensesTab(bool isDark, Color surface, Color text, Color sub) {
    if (_loadingExpenses) {
      return Center(child: CircularProgressIndicator(color: DhanWiserColors.primary));
    }

    if (_expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        subtitle: 'Tap + to add the first one',
      );
    }

    final categoryIcons = [Icons.restaurant_rounded, Icons.directions_car_rounded, Icons.home_rounded, Icons.movie_rounded, Icons.shopping_cart_rounded, Icons.lightbulb_rounded, Icons.sports_esports_rounded, Icons.coffee_rounded];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final e = _expenses[index];
        final catIcon = categoryIcons[e.title.hashCode.abs() % categoryIcons.length];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(catIcon, color: DhanWiserColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paid by ${e.createdByUsername}',
                      style: GoogleFonts.inter(fontSize: 12, color: sub),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${e.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── BALANCES TAB ──
  Widget _buildBalancesTab(bool isDark, Color surface, Color text, Color sub) {
    if (_loadingBalances) {
      return Center(child: CircularProgressIndicator(color: DhanWiserColors.primary));
    }

    if (_balances.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_outlined,
        title: 'All settled up!',
        subtitle: 'No outstanding balances',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance cards
          ..._balances.map((b) {
            final isPositive = b.balance >= 0;
            final color = isPositive ? DhanWiserColors.teal : DhanWiserColors.coral;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        b.fullName.isNotEmpty ? b.fullName[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.fullName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: text,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '@${b.username}',
                          style: GoogleFonts.inter(fontSize: 12, color: sub),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${b.balance.abs().toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      Text(
                        isPositive ? 'gets back' : 'owes',
                        style: GoogleFonts.inter(fontSize: 11, color: color.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Suggestions
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'SETTLE UP',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sub,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            ..._suggestions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.1 : 0.04),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    s.fromUsername,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 14),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: DhanWiserColors.primary),
                  ),
                  Text(
                    s.toUsername,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '₹${s.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: DhanWiserColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── MEMBERS TAB ──
  Widget _buildMembersTab(bool isDark, Color surface, Color text, Color sub) {
    return Consumer<ServerProvider>(
      builder: (context, serverProv, _) {
        if (serverProv.isLoading) {
          return Center(child: CircularProgressIndicator(color: DhanWiserColors.primary));
        }

        final members = serverProv.currentServerDetail?.members ?? [];
        if (members.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No members',
            subtitle: 'Invite friends to this group',
          );
        }

        final memberColors = [
          DhanWiserColors.primary,
          DhanWiserColors.teal,
          DhanWiserColors.coral,
          DhanWiserColors.warning,
          const Color(0xFF74B9FF),
        ];

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final m = members[index];
            final color = memberColors[index % memberColors.length];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Center(
                      child: Text(
                        m.fullName.isNotEmpty ? m.fullName[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.fullName,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: text, fontSize: 15),
                        ),
                        Text(
                          '@${m.username}',
                          style: GoogleFonts.inter(fontSize: 12, color: sub),
                        ),
                      ],
                    ),
                  ),
                  if (m.role == 'admin')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DhanWiserColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Admin',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DhanWiserColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 30, color: DhanWiserColors.primary.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
