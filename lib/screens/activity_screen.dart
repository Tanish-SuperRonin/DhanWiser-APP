import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/notification_provider.dart';
import '../providers/server_provider.dart';
import '../services/notification_service.dart';
import '../services/server_service.dart';
import '../models/notification_model.dart';
import '../models/server_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ServerInvitation> _invitations = [];
  bool _loadingInvitations = true;

  // Track which invitations are being responded to
  final Set<int> _respondingIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
      _loadInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notifProvider.fetchNotifications();
  }

  Future<void> _loadInvitations() async {
    try {
      _invitations = await ServerService.getInvitations();
    } catch (_) {}
    _loadingInvitations = false;
    if (mounted) setState(() {});
  }

  Future<void> _respondToInvitation(int invitationId, String action) async {
    setState(() => _respondingIds.add(invitationId));
    try {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      final notifProv =
          Provider.of<NotificationProvider>(context, listen: false);
      await serverProv.respondToInvitation(invitationId, action);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                action == 'accept' ? 'Joined the group!' : 'Invitation declined'),
            backgroundColor:
                action == 'accept' ? DhanWiserColors.mint : DhanWiserColors.coral,
          ),
        );
        await _loadInvitations();
        await notifProv.fetchNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: DhanWiserColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _respondingIds.remove(invitationId));
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expense_added':
        return Icons.receipt_long_rounded;
      case 'settlement_requested':
      case 'settlement_request':
        return Icons.handshake_rounded;
      case 'settlement_approved':
        return Icons.check_circle_rounded;
      case 'settlement_rejected':
        return Icons.cancel_rounded;
      case 'payment_reminder':
        return Icons.notifications_active_rounded;
      case 'invitation':
      case 'server_invitation':
        return Icons.mail_rounded;
      case 'server_joined':
        return Icons.group_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'expense_added':
        return DhanWiserColors.primary;
      case 'settlement_requested':
      case 'settlement_request':
        return DhanWiserColors.warning;
      case 'settlement_approved':
        return DhanWiserColors.mint;
      case 'settlement_rejected':
        return DhanWiserColors.coral;
      case 'payment_reminder':
        return DhanWiserColors.warning;
      case 'invitation':
      case 'server_invitation':
        return DhanWiserColors.tertiary;
      case 'server_joined':
        return DhanWiserColors.teal;
      default:
        return DhanWiserColors.primary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? cs.surfaceContainerHigh
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: cs.onPrimary,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w400, fontSize: 13),
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(3),
                tabs: [
                  const Tab(text: 'Notifications'),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Invitations'),
                        if (_invitations.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Badge(
                            label: Text('${_invitations.length}'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(cs, isDark),
          _buildInvitationsTab(cs, isDark),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab(ColorScheme cs, bool isDark) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProv, _) {
        if (notifProv.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: cs.primary),
          );
        }

        final notifications = notifProv.notifications;
        if (notifications.isEmpty) {
          return _buildEmptyState(
            cs,
            isDark,
            Icons.notifications_outlined,
            'No activity yet',
            'Your notifications will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          color: cs.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(notifications[index], cs, isDark);
            },
          ),
        );
      },
    );
  }

  Widget _buildInvitationsTab(ColorScheme cs, bool isDark) {
    if (_loadingInvitations) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_invitations.isEmpty) {
      return _buildEmptyState(
        cs,
        isDark,
        Icons.mail_outline_rounded,
        'No invitations',
        'Group invitations will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: cs.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          return _buildInvitationItem(_invitations[index], cs, isDark);
        },
      ),
    );
  }

  Widget _buildEmptyState(
      ColorScheme cs, bool isDark, IconData icon, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: cs.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationItem(
      ServerInvitation invitation, ColorScheme cs, bool isDark) {
    final isResponding = _respondingIds.contains(invitation.id);
    final initial = invitation.serverName.isNotEmpty
        ? invitation.serverName[0].toUpperCase()
        : 'G';
    final time = invitation.createdAt != null
        ? _formatTime(invitation.createdAt!)
        : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.inter(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.serverName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Invited by ${invitation.inviterName ?? invitation.inviterUsername}',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (time.isNotEmpty)
                  Text(time,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ),
            if (invitation.serverDescription != null &&
                invitation.serverDescription!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                invitation.serverDescription!,
                style: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isResponding
                        ? null
                        : () =>
                            _respondToInvitation(invitation.id, 'reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DhanWiserColors.coral,
                      side: BorderSide(
                        color: DhanWiserColors.coral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isResponding
                        ? null
                        : () =>
                            _respondToInvitation(invitation.id, 'accept'),
                    style: FilledButton.styleFrom(
                      backgroundColor: DhanWiserColors.mint,
                      foregroundColor: Colors.white,
                    ),
                    child: isResponding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Accept & Join'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      AppNotification notification, ColorScheme cs, bool isDark) {
    final notifIcon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final time = notification.createdAt != null
        ? _formatTime(notification.createdAt!)
        : '';
    final isInvitationNotification =
        (notification.type == 'server_invitation' ||
                notification.type == 'invitation') &&
            notification.relatedId != null;
    final isResponding = isInvitationNotification &&
        _respondingIds.contains(notification.relatedId!);

    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: cs.onErrorContainer, size: 22),
      ),
      onDismissed: (_) async {
        final notifProv =
            Provider.of<NotificationProvider>(context, listen: false);
        try {
          await NotificationService.deleteNotification(notification.id);
          notifProv.fetchNotifications();
        } catch (_) {}
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (notification.type == 'server_invitation' ||
                notification.type == 'invitation') {
              _tabController.animateTo(1);
              _loadInvitations();
              return;
            }

            if (notification.type == 'settlement_request' &&
                notification.relatedId != null) {
              final handled = await Navigator.pushNamed(
                context,
                '/settlement-request',
                arguments: {'settlementId': notification.relatedId},
              );

              if (handled == true && mounted) {
                await _loadNotifications();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(notifIcon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.message,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: cs.onSurface,
                              height: 1.4,
                            ),
                            maxLines: isInvitationNotification ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (time.isNotEmpty)
                                Text(time,
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant)),
                              if (notification.type == 'server_invitation' ||
                                  notification.type == 'invitation' ||
                                  notification.type ==
                                      'settlement_request') ...[
                                const SizedBox(width: 8),
                                Text(
                                  isInvitationNotification
                                      ? 'Respond here or tap to view'
                                      : notification.type ==
                                              'settlement_request'
                                          ? 'Tap to review →'
                                          : 'Tap to view →',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: cs.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!notification.isRead)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 8),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                if (isInvitationNotification) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isResponding
                              ? null
                              : () => _respondToInvitation(
                                    notification.relatedId!,
                                    'reject',
                                  ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DhanWiserColors.coral,
                            side: BorderSide(
                              color:
                                  DhanWiserColors.coral.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: isResponding
                              ? null
                              : () => _respondToInvitation(
                                    notification.relatedId!,
                                    'accept',
                                  ),
                          style: FilledButton.styleFrom(
                            backgroundColor: DhanWiserColors.mint,
                            foregroundColor: Colors.white,
                          ),
                          child: isResponding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
