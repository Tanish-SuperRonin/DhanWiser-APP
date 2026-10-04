import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/iconly_icons.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../services/expense_service.dart';
import '../models/balance_model.dart';
import '../widgets/bouncing_button.dart';

class ProfileScreen extends StatefulWidget {
  final bool isRootTab;
  const ProfileScreen({super.key, this.isRootTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _groupCount = 0;
  double _totalOwed = 0.0;
  double _totalOwe = 0.0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    if (serverProv.servers.isEmpty) {
      await serverProv.fetchServers();
    }

    double owedSum = 0.0;
    double oweSum = 0.0;
    final currentUser = authProv.currentUser;

    if (currentUser != null) {
      for (final s in serverProv.servers) {
        try {
          final res = await ExpenseService.getServerBalances(s.id);
          final balances = res['balances'] as List<BalanceModel>;
          for (final b in balances) {
            if (b.userId == currentUser.id) {
              if (b.balance > 0) owedSum += b.balance;
              if (b.balance < 0) oweSum += b.balance.abs();
            }
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _groupCount = serverProv.servers.length;
        _totalOwed = owedSum;
        _totalOwe = oweSum;
        _loadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: widget.isRootTab
            ? null
            : PremiumIconButton(
                icon: Icon(IconlyLight.arrowLeft2, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Profile & Settings',
          style: DhanWiserTextStyles.title2(context).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colors.card,
              shape: BoxShape.circle,
              border: Border.all(color: colors.cardBorder),
            ),
            child: PremiumIconButton(
              icon: Icon(IconlyLight.setting, color: colors.textPrimary, size: 20),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'Member';
          final username = user?.username.isNotEmpty == true ? user!.username : 'member';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
          final upiId = user?.upiId;

          return RefreshIndicator(
            onRefresh: _loadStats,
            color: colors.primary,
            backgroundColor: colors.card,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero User Identity Card ──
                  _buildProfileHero(context, colors, isDark, name, username, initial, upiId),
                  const SizedBox(height: 24),

                  // ── Lifetime Bento Grid ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Financial Snapshot',
                        style: DhanWiserTextStyles.title2(context).copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'All Groups',
                          style: DhanWiserTextStyles.overline(context).copyWith(
                            color: isDark ? colors.primary : colors.emerald,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildBentoFinancialStats(colors, isDark),
                  const SizedBox(height: 28),

                  // ── Milestones & Achievements ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Milestones & Badges',
                        style: DhanWiserTextStyles.title2(context).copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '2/3 Unlocked',
                        style: DhanWiserTextStyles.caption(context).copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMilestoneCard(
                    icon: IconlyBold.shieldDone,
                    iconColor: colors.emerald,
                    badgeColor: colors.emerald.withValues(alpha: 0.12),
                    title: 'Swift Settler',
                    subtitle: 'Settled 10 balances within 24 hours of request',
                    statusText: 'Active',
                    isUnlocked: true,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),
                  _buildMilestoneCard(
                    icon: IconlyBold.wallet,
                    iconColor: colors.secondary,
                    badgeColor: colors.secondary.withValues(alpha: 0.12),
                    title: 'Group Anchor',
                    subtitle: 'Shared expenses across multiple active circles',
                    statusText: 'Unlocked',
                    isUnlocked: true,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),
                  _buildMilestoneCard(
                    icon: IconlyLight.shieldFail,
                    iconColor: colors.textDisabled,
                    badgeColor: colors.card,
                    title: 'Zero Balance Guardian',
                    subtitle: 'Maintain 0 pending debt across circles for 30 days',
                    statusText: 'Locked',
                    isUnlocked: false,
                    colors: colors,
                  ),
                  const SizedBox(height: 28),

                  // ── Quick Preferences & Settings ──
                  Text(
                    'Preferences & Account',
                    style: DhanWiserTextStyles.title2(context).copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPreferencesGroup(context, colors, isDark, upiId, name, username),
                  const SizedBox(height: 32),

                  // ── Sign Out Button ──
                  BouncingButton(
                    onTap: () => _confirmSignOut(context, colors),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.carmine.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.carmine.withValues(alpha: isDark ? 0.3 : 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconlyLight.logout, color: colors.carmine, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Out of DhanWiser',
                            style: DhanWiserTextStyles.bodyBold(context).copyWith(
                              color: colors.carmine,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'DhanWiser v2.4.0 • Built with precision & luxury',
                      style: DhanWiserTextStyles.caption(context).copyWith(
                        color: colors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Profile Hero Widget ──
  Widget _buildProfileHero(
    BuildContext context,
    DhanWiserColors colors,
    bool isDark,
    String name,
    String username,
    String initial,
    String? upiId,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cardBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with subtle glow ring
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? colors.surfaceContainer : const Color(0xFF0F172A),
                      border: Border.all(
                        color: colors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: DhanWiserTextStyles.headline1(context).copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: isDark ? colors.primary : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.emerald,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.card, width: 2.5),
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              // Name and handle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: DhanWiserTextStyles.title1(context).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: isDark ? colors.primary : const Color(0xFF0284C7),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '@$username',
                      style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                        color: colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Member since 2024',
                        style: DhanWiserTextStyles.overline(context).copyWith(
                          color: colors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 16),

          // UPI & Edit Profile Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (upiId != null && upiId.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: upiId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('UPI ID copied: $upiId'),
                          backgroundColor: colors.emerald,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      _showEditProfileModal(context, name, username, upiId);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_rounded,
                          size: 16,
                          color: upiId != null ? colors.emerald : colors.textDisabled,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            upiId != null && upiId.isNotEmpty ? upiId : 'Add UPI for instant pay',
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: upiId != null ? colors.textPrimary : colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (upiId != null)
                          Icon(Icons.copy_rounded, size: 14, color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BouncingButton(
                onTap: () => _showEditProfileModal(context, name, username, upiId),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? colors.surfaceBright : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? colors.cardBorder : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        IconlyLight.edit,
                        size: 15,
                        color: isDark ? colors.textPrimary : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: DhanWiserTextStyles.bodyBold(context).copyWith(
                          fontSize: 13,
                          color: isDark ? colors.textPrimary : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bento Grid Financial Stats ──
  Widget _buildBentoFinancialStats(DhanWiserColors colors, bool isDark) {
    return Column(
      children: [
        // Main Bento: Total Settled / Owed Volume
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL RECEIVABLE (LIFETIME)',
                    style: DhanWiserTextStyles.overline(context).copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.emerald.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(IconlyLight.arrowUp2, color: colors.emerald, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _loadingStats ? '...' : CurrencyFormatter.format(_totalOwed),
                style: DhanWiserTextStyles.displayLarge(context).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Calculated across all shared group splits and tabs',
                style: DhanWiserTextStyles.caption(context).copyWith(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Split Bento Row: You Owe & Active Groups
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'YOU OWE',
                          style: DhanWiserTextStyles.overline(context).copyWith(
                            color: colors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Icon(IconlyLight.arrowDown2, color: colors.carmine, size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _loadingStats ? '...' : CurrencyFormatter.format(_totalOwe),
                      style: DhanWiserTextStyles.title1(context).copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _totalOwe > 0 ? colors.carmine : colors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _totalOwe > 0 ? 'Pending repayment' : 'All clear',
                      style: DhanWiserTextStyles.caption(context).copyWith(
                        color: _totalOwe > 0 ? colors.carmine : colors.emerald,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CIRCLES',
                          style: DhanWiserTextStyles.overline(context).copyWith(
                            color: colors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Icon(IconlyBold.user2, color: const Color(0xFF0284C7), size: 16),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_groupCount',
                      style: DhanWiserTextStyles.title1(context).copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Active groups',
                      style: DhanWiserTextStyles.caption(context).copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Milestone Card ──
  Widget _buildMilestoneCard({
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String statusText,
    required bool isUnlocked,
    required DhanWiserColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: DhanWiserTextStyles.bodyBold(context).copyWith(
                        color: isUnlocked ? colors.textPrimary : colors.textDisabled,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: DhanWiserTextStyles.caption(context).copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? colors.emerald.withValues(alpha: 0.12)
                  : colors.surfaceContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              statusText,
              style: DhanWiserTextStyles.overline(context).copyWith(
                color: isUnlocked ? colors.emerald : colors.textDisabled,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Preferences Group ──
  Widget _buildPreferencesGroup(
    BuildContext context,
    DhanWiserColors colors,
    bool isDark,
    String? upiId,
    String name,
    String username,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: IconlyLight.profile,
            title: 'Edit Personal Details',
            subtitle: 'Name, handle & account info',
            onTap: () => _showEditProfileModal(context, name, username, upiId),
            colors: colors,
          ),
          Divider(color: colors.divider, height: 1),
          _buildSettingsTile(
            icon: IconlyLight.wallet,
            title: 'UPI & Payment Methods',
            subtitle: upiId != null && upiId.isNotEmpty ? upiId : 'Not configured',
            onTap: () => _showEditProfileModal(context, name, username, upiId),
            colors: colors,
          ),
          Divider(color: colors.divider, height: 1),
          _buildSettingsTile(
            icon: IconlyLight.notification,
            title: 'Notifications & Alerts',
            subtitle: 'Push notifications & reminders',
            onTap: () => Navigator.pushNamed(context, '/settings'),
            colors: colors,
          ),
          Divider(color: colors.divider, height: 1),
          _buildSettingsTile(
            icon: IconlyLight.lock,
            title: 'Security & App Lock',
            subtitle: 'PIN, biometric & active sessions',
            onTap: () => Navigator.pushNamed(context, '/settings'),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required DhanWiserColors colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors.textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DhanWiserTextStyles.bodyBold(context).copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DhanWiserTextStyles.caption(context).copyWith(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(IconlyLight.arrowRight2, color: colors.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Sign Out Confirmation Dialog ──
  void _confirmSignOut(BuildContext context, DhanWiserColors colors) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: DhanWiserTextStyles.title2(context).copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out of DhanWiser? Your local data will be safely synchronized.',
          style: DhanWiserTextStyles.bodyRegular(context).copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: DhanWiserTextStyles.bodyBold(context).copyWith(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.carmine,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ── Edit Profile Modal Sheet ──
  void _showEditProfileModal(
    BuildContext context,
    String currentName,
    String currentUsername,
    String? currentUpiId,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final upiCtrl = TextEditingController(text: currentUpiId ?? '');
    bool isSaving = false;
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.cardBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Edit Profile',
                    style: DhanWiserTextStyles.title1(context).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep your display name and UPI settlement handle updated.',
                    style: DhanWiserTextStyles.caption(context).copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  Text(
                    'FULL DISPLAY NAME',
                    style: DhanWiserTextStyles.overline(context).copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    style: DhanWiserTextStyles.bodyBold(context).copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Your name',
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // UPI ID
                  Text(
                    'UPI ID (FOR RECEIVING PAYMENTS)',
                    style: DhanWiserTextStyles.overline(context).copyWith(
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: upiCtrl,
                    style: DhanWiserTextStyles.bodyBold(context).copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. username@okhdfcbank',
                      prefixIcon: Icon(Icons.qr_code_rounded, color: colors.emerald, size: 20),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save Changes Button
                  BouncingButton(
                    onTap: isSaving
                        ? null
                        : () async {
                            setModalState(() => isSaving = true);
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            await auth.updateProfile(
                              fullName: nameCtrl.text.trim(),
                              upiId: upiCtrl.text.trim().isEmpty ? null : upiCtrl.text.trim(),
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Profile updated successfully'),
                                  backgroundColor: colors.emerald,
                                ),
                              );
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? colors.primary : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: isDark ? colors.background : Colors.white,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: DhanWiserTextStyles.bodyBold(context).copyWith(
                                color: isDark ? colors.background : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
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
}
