import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';
import '../services/expense_service.dart';
import '../models/balance_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    return Scaffold(
      backgroundColor: DhanWiserColors.background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: DhanWiserColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: DhanWiserColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: DhanWiserColors.textSecondary),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          final name = user?.fullName.isNotEmpty == true ? user!.fullName : 'User';
          final username = user?.username.isNotEmpty == true ? user!.username : 'user';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Avatar & Profile Summary
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: DhanWiserColors.surfaceVariant,
                            border: Border.all(color: DhanWiserColors.surfaceContainerHighest, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: DhanWiserColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: DhanWiserColors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(color: DhanWiserColors.surfaceContainerLow),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit_rounded, size: 16, color: DhanWiserColors.textPrimary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit avatar coming soon')));
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: DhanWiserColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@$username • Member since 2024',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: DhanWiserColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: user == null ? null : () => _showEditProfileModal(context, name, username, user.upiId),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: DhanWiserColors.surfaceContainerHigh,
                        side: BorderSide(color: DhanWiserColors.outlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: DhanWiserColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Lifetime Stats (Bento Grid)
                Text(
                  'Lifetime Stats',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: DhanWiserColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                
                // Total Settled (Positive)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: DhanWiserColors.card.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: DhanWiserColors.tertiaryContainer.withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL SETTLED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: DhanWiserColors.textSecondary,
                            ),
                          ),
                          Icon(Icons.trending_up_rounded, color: DhanWiserColors.tertiaryContainer, size: 20),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _loadingStats
                            ? '...'
                            : '₹${_totalOwed.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: DhanWiserColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                
                Row(
                  children: [
                    // Total Owed / Spent
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.card.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: DhanWiserColors.secondary.withValues(alpha: 0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL YOU OWE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: DhanWiserColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _loadingStats
                                  ? '...'
                                  : '₹${_totalOwe.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: DhanWiserColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.arrow_downward_rounded, color: DhanWiserColors.secondary, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'This year',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: DhanWiserColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Active Groups
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DhanWiserColors.card.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ACTIVE GROUPS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: DhanWiserColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$_groupCount',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: DhanWiserColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.group_rounded, color: DhanWiserColors.textDisabled, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Groups joined',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: DhanWiserColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Recent Achievements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Achievements',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: DhanWiserColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DhanWiserColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                _buildAchievementItem(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: DhanWiserColors.tertiaryContainer,
                  title: 'Early Settler',
                  description: 'Settled 10 expenses within 24h',
                ),
                _buildAchievementItem(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: DhanWiserColors.secondary,
                  title: 'Big Spender',
                  description: 'Contributed over ₹5k in groups',
                ),
                _buildAchievementItem(
                  icon: Icons.lock_rounded,
                  iconColor: DhanWiserColors.textDisabled,
                  title: 'Perfect Balance',
                  description: 'Maintain 0 balance for 30 days',
                  isLocked: true,
                ),

                SizedBox(height: 32),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DhanWiserColors.error,
                      side: BorderSide(color: DhanWiserColors.error.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Sign Out', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isLocked = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: DhanWiserColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Opacity(
              opacity: isLocked ? 0.6 : 1.0,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: isLocked ? DhanWiserColors.textDisabled : DhanWiserColors.textPrimary,
                          ),
                        ),
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isLocked ? DhanWiserColors.textDisabled : DhanWiserColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Icon(Icons.chevron_right_rounded, color: DhanWiserColors.textDisabled),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, String currentName, String currentUsername, String? currentUpiId) {
    final nameCtrl = TextEditingController(text: currentName);
    final upiCtrl = TextEditingController(text: currentUpiId ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DhanWiserColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DhanWiserColors.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edit Profile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: DhanWiserColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FULL NAME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(color: DhanWiserColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: DhanWiserColors.surfaceContainer,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'UPI ID (FOR SETTLEMENTS)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DhanWiserColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: upiCtrl,
                    style: GoogleFonts.inter(color: DhanWiserColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'name@okbank',
                      filled: true,
                      fillColor: DhanWiserColors.surfaceContainer,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: isSaving
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
                                  const SnackBar(content: Text('Profile updated successfully!')),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: DhanWiserColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Save Changes', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
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

