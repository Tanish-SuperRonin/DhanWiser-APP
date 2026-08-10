import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: PremiumIconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Appearance Section ──
          _buildSectionHeader(context, 'Appearance', cs),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProv, _) {
                    return SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: Theme.of(context).textTheme.titleSmall!,
                      ),
                      subtitle: Text(
                        isDark ? 'Using dark theme' : 'Using light theme',
                        style: DhanWiserTextStyles.caption(context)
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      secondary: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: cs.primary,
                      ),
                      value: themeProv.themeMode == ThemeMode.dark,
                      onChanged: (_) => themeProv.toggleTheme(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Account Section ──
          _buildSectionHeader(context, 'Account', cs),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.person_outline_rounded, color: cs.primary),
                  title: Text('Profile',
                      style: Theme.of(context).textTheme.titleSmall!),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: cs.outlineVariant),
                ListTile(
                  leading:
                      Icon(Icons.notifications_outlined, color: cs.primary),
                  title: Text('Notifications',
                      style: Theme.of(context).textTheme.titleSmall!),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant),
                  onTap: () => Navigator.pushNamed(context, '/activity'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── More Section ──
          _buildSectionHeader(context, 'More', cs),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.handshake_outlined, color: cs.primary),
                  title: Text('Settlements',
                      style: Theme.of(context).textTheme.titleSmall!),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant),
                  onTap: () => Navigator.pushNamed(context, '/settlement'),
                ),
                Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: cs.outlineVariant),
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: cs.primary),
                  title: Text('About DhanWiser',
                      style: Theme.of(context).textTheme.titleSmall!),
                  subtitle: Text(
                    'Version 1.0.0',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: cs.onSurfaceVariant),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'DhanWiser',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 DhanWiser',
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: cs.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Danger Zone ──
          _buildSectionHeader(context, 'Danger Zone', cs),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: cs.error),
              title: Text(
                'Sign Out',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: cs.error),
              ),
              onTap: () => _showLogoutDialog(context, cs, isDark),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(color: cs.primary, letterSpacing: 0.2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ColorScheme cs, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: cs.error, size: 32),
          title: const Text('Sign Out'),
          content:
              const Text('Are you sure you want to sign out of DhanWiser?'),
          actions: [
            PremiumTextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            PremiumFilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performLogout(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
