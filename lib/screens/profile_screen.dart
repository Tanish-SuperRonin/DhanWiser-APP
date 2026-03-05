import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.currentUser;
            final name = user?.fullName ?? 'User';
            final username = user?.username ?? 'user';
            final email = user?.email ?? '';
            final upi = user?.upiId;
            final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Top bar ──
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? DhanWiserColors.surfaceElevatedDark : DhanWiserColors.gray100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.settings_outlined, color: sub, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Avatar with gradient ring ──
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [DhanWiserColors.primary, DhanWiserColors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? DhanWiserColors.surfaceDark : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: DhanWiserColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: DhanWiserColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Stats row ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                        _StatItem(value: '—', label: 'Groups', color: DhanWiserColors.primary),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200,
                        ),
                        _StatItem(value: '—', label: 'Splits', color: DhanWiserColors.teal),
                        Container(
                          width: 1,
                          height: 36,
                          color: isDark ? DhanWiserColors.gray700 : DhanWiserColors.gray200,
                        ),
                        _StatItem(value: '—', label: 'Settled', color: DhanWiserColors.mint),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Info section ──
                  _buildSection(
                    isDark: isDark,
                    text: text, sub: sub,
                    title: 'Account',
                    items: [
                      _InfoRow(Icons.mail_outline_rounded, 'Email', email),
                      if (upi != null && upi.isNotEmpty)
                        _InfoRow(Icons.account_balance_outlined, 'UPI ID', upi),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Actions section ──
                  _buildSection(
                    isDark: isDark,
                    text: text, sub: sub,
                    title: 'Quick Actions',
                    items: [
                      _InfoRow(Icons.group_outlined, 'Your Groups', 'View all'),
                      _InfoRow(Icons.receipt_long_outlined, 'Activity', 'Recent splits'),
                      _InfoRow(Icons.handshake_outlined, 'Settlements', 'Pending'),
                    ],
                    onTaps: [
                      () => Navigator.pushNamed(context, '/home'),
                      () => Navigator.pushNamed(context, '/activity'),
                      () => Navigator.pushNamed(context, '/settlement'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Logout ──
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: DhanWiserColors.coral.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.inter(
                          color: DhanWiserColors.coral,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required Color text,
    required Color sub,
    required String title,
    required List<_InfoRow> items,
    List<VoidCallback>? onTaps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sub,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return GestureDetector(
                onTap: onTaps != null && index < onTaps.length ? onTaps[index] : null,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: DhanWiserColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: text,
                              ),
                            ),
                          ),
                          Text(
                            item.value,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: sub,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (onTaps != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.chevron_right_rounded, color: sub, size: 18),
                            ),
                        ],
                      ),
                      if (!isLast)
                        Padding(
                          padding: const EdgeInsets.only(top: 12, left: 48),
                          child: Divider(
                            height: 1,
                            color: isDark ? DhanWiserColors.gray700.withValues(alpha: 0.5) : DhanWiserColors.gray200,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? DhanWiserColors.textSecondaryDark
                  : DhanWiserColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
