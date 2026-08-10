import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../providers/server_provider.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class GroupSettingsScreen extends StatefulWidget {
  final int serverId;
  final String serverName;
  final bool isAdmin;
  final bool isCreator;

  const GroupSettingsScreen({
    super.key,
    required this.serverId,
    required this.serverName,
    required this.isAdmin,
    required this.isCreator,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  void _confirmDeleteOrLeave(
      {required bool canDelete, required String groupName}) {
    final title = canDelete ? 'Delete Group?' : 'Leave Group?';
    final desc = canDelete
        ? 'Are you sure you want to delete "$groupName"? All expenses and balances will be lost forever. This cannot be undone.'
        : 'Are you sure you want to leave "$groupName"?';
    final confirmText = canDelete ? 'Delete' : 'Leave';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DhanWiserColors.of(context).surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: DhanWiserColors.of(context).onSurface)),
        content: Text(desc,
            style: DhanWiserTextStyles.caption(context)
                .copyWith(color: DhanWiserColors.of(context).onSurfaceVariant)),
        actions: [
          PremiumTextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: DhanWiserTextStyles.caption(context)
                    .copyWith(color: DhanWiserColors.of(context).primary)),
          ),
          PremiumElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DhanWiserColors.of(context).coral,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final sp = Provider.of<ServerProvider>(context, listen: false);
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              bool success = false;
              if (canDelete) {
                success = await sp.deleteServer(widget.serverId);
              } else {
                success = await sp.leaveServer(widget.serverId);
              }

              if (success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(canDelete ? 'Group deleted' : 'Left group'),
                    backgroundColor: DhanWiserColors.of(context).teal,
                  ),
                );
                // Pop back to home
                navigator.popUntil((route) => route.isFirst);
              } else {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(sp.error ?? 'Action failed'),
                    backgroundColor: DhanWiserColors.of(context).coral,
                  ),
                );
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _copyInviteLink() {
    Clipboard.setData(
        ClipboardData(text: 'https://dhanwiser.app/join/${widget.serverId}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied to clipboard'),
        backgroundColor: DhanWiserColors.of(context).primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.of(context).background.withValues(alpha: 0.8),
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Group Settings',
          style: DhanWiserTextStyles.buttonLarge(context)
              .copyWith(color: DhanWiserColors.of(context).primary),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: DhanWiserColors.of(context).surfaceContainer.withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('General'),
          _buildSettingsItem(
            icon: Icons.edit_rounded,
            title: 'Edit Group Name',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit name coming soon')),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.link_rounded,
            title: 'Copy Invite Link',
            onTap: _copyInviteLink,
          ),
          if (widget.isAdmin) ...[
            SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildSettingsItem(
              icon: Icons.notifications_active_rounded,
              title: 'Reminder Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminders config coming soon')),
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('Danger Zone'),
          if (!widget.isCreator)
            _buildSettingsItem(
              icon: Icons.exit_to_app_rounded,
              title: 'Leave Group',
              isDestructive: true,
              onTap: () => _confirmDeleteOrLeave(
                  canDelete: false, groupName: widget.serverName),
            ),
          if (widget.isCreator)
            _buildSettingsItem(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Group',
              isDestructive: true,
              onTap: () => _confirmDeleteOrLeave(
                  canDelete: true, groupName: widget.serverName),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: DhanWiserTextStyles.overline(context)
            .copyWith(letterSpacing: 1.2, color: DhanWiserColors.of(context).textDisabled),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? DhanWiserColors.of(context).error : DhanWiserColors.of(context).textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: DhanWiserColors.of(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DhanWiserColors.of(context).surfaceContainer),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDestructive
                            ? DhanWiserColors.of(context).error
                            : DhanWiserColors.of(context).textPrimary),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: DhanWiserColors.of(context).textDisabled, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
