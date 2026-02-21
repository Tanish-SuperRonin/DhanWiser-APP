import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;
    final surface = isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
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
                  const SizedBox(width: 14),
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Account ──
                    _sectionTitle('Account', sub),
                    const SizedBox(height: 10),
                    _card(surface, isDark, [
                      _navTile(Icons.person_outline_rounded, 'Edit Profile',
                          'Update your info', text, sub,
                          () => Navigator.pushNamed(context, '/profile')),
                      _divider(isDark),
                      _navTile(Icons.lock_outline_rounded, 'Change Password',
                          'Update credentials', text, sub, () {}),
                      _divider(isDark),
                      _navTile(Icons.payment_rounded, 'Payment Methods',
                          'UPI & bank accounts', text, sub, () {}),
                    ]),

                    const SizedBox(height: 24),

                    // ── Appearance ──
                    _sectionTitle('Appearance', sub),
                    const SizedBox(height: 10),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProv, _) => _card(surface, isDark, [
                        _toggleTile(Icons.dark_mode_rounded,
                            'Dark Mode', text, sub,
                            themeProv.isDark, (_) => themeProv.toggleTheme()),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── Notifications ──
                    _sectionTitle('Notifications', sub),
                    const SizedBox(height: 10),
                    _card(surface, isDark, [
                      _toggleTile(Icons.notifications_active_outlined,
                          'Push Notifications', text, sub,
                          _pushNotifications, (v) => setState(() => _pushNotifications = v)),
                      _divider(isDark),
                      _toggleTile(Icons.email_outlined,
                          'Email Alerts', text, sub,
                          _emailAlerts, (v) => setState(() => _emailAlerts = v)),
                    ]),

                    const SizedBox(height: 24),

                    // ── About ──
                    _sectionTitle('About', sub),
                    const SizedBox(height: 10),
                    _card(surface, isDark, [
                      _navTile(Icons.info_outline_rounded, 'About DhanWiser',
                          'Version 1.0.0', text, sub, () {}),
                      _divider(isDark),
                      _navTile(Icons.description_outlined, 'Terms of Service',
                          null, text, sub, () {}),
                      _divider(isDark),
                      _navTile(Icons.shield_outlined, 'Privacy Policy',
                          null, text, sub, () {}),
                    ]),

                    const SizedBox(height: 28),

                    // ── Sign out ──
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          final auth = Provider.of<AuthProvider>(context, listen: false);
                          await auth.logout();
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _card(Color surface, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: isDark
            ? DhanWiserColors.gray700.withValues(alpha: 0.5)
            : DhanWiserColors.gray200,
      ),
    );
  }

  Widget _navTile(IconData icon, String title, String? subtitle,
      Color text, Color sub, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DhanWiserColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: DhanWiserColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w500, color: text)),
                  if (subtitle != null)
                    Text(subtitle, style: GoogleFonts.inter(
                      fontSize: 12, color: sub)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: sub, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile(IconData icon, String title, Color text, Color sub,
      bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DhanWiserColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: DhanWiserColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w500, color: text)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: DhanWiserColors.primary,
          ),
        ],
      ),
    );
  }
}
