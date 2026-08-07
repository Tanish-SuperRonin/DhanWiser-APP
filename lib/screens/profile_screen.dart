import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/server_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _groupCount = 0;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  Future<void> _loadStats() async {
    final serverProv = Provider.of<ServerProvider>(context, listen: false);
    if (serverProv.servers.isEmpty) {
      await serverProv.fetchServers();
    }
    if (mounted) {
      setState(() {
        _groupCount = serverProv.servers.length;
        _statsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
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
                const SizedBox(height: 16),

                // ── Avatar with gradient ring ──
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.primary, DhanWiserColors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surface,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
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
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Stats row — M3 Card ──
                Card(
                  elevation: 0,
                  color: isDark
                      ? cs.surfaceContainerHigh
                      : cs.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        _StatItem(
                          value: _statsLoaded ? '$_groupCount' : '—',
                          label: 'Groups',
                          color: cs.primary,
                          cs: cs,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: cs.outlineVariant,
                        ),
                        _StatItem(
                          value: '—',
                          label: 'Splits',
                          color: DhanWiserColors.teal,
                          cs: cs,
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: cs.outlineVariant,
                        ),
                        _StatItem(
                          value: '—',
                          label: 'Settled',
                          color: DhanWiserColors.mint,
                          cs: cs,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Account info — M3 Card ──
                _buildSectionHeader('Account', cs),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: isDark
                      ? cs.surfaceContainerHigh
                      : cs.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.mail_outline_rounded,
                            color: cs.primary, size: 22),
                        title: Text('Email',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        trailing: Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (upi != null && upi.isNotEmpty) ...[
                        Divider(
                            height: 1,
                            indent: 56,
                            endIndent: 16,
                            color: cs.outlineVariant),
                        ListTile(
                          leading: Icon(Icons.account_balance_outlined,
                              color: cs.primary, size: 22),
                          title: Text('UPI ID',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500)),
                          trailing: Text(
                            upi,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quick Actions ──
                _buildSectionHeader('Quick Actions', cs),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: isDark
                      ? cs.surfaceContainerHigh
                      : cs.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.group_outlined,
                            color: cs.primary, size: 22),
                        title: Text('Your Groups',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text('View all',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                        onTap: () =>
                            Navigator.pushNamed(context, '/home'),
                      ),
                      Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: cs.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.receipt_long_outlined,
                            color: cs.primary, size: 22),
                        title: Text('Activity',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text('Recent splits',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                        onTap: () =>
                            Navigator.pushNamed(context, '/activity'),
                      ),
                      Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: cs.outlineVariant),
                      ListTile(
                        leading: Icon(Icons.handshake_outlined,
                            color: cs.primary, size: 22),
                        title: Text('Settlements',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text('Pending',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: cs.onSurfaceVariant)),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                        onTap: () =>
                            Navigator.pushNamed(context, '/settlement'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign Out ──
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(
                        color: cs.error.withValues(alpha: 0.3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Sign Out'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.primary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final ColorScheme cs;
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.cs,
  });

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
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
