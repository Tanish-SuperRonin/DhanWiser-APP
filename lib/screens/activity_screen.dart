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
        return DhanWiserColors.warning;
      case 'settlement_approved':
        return DhanWiserColors.mint;
      case 'settlement_rejected':
        return DhanWiserColors.coral;
      case 'payment_reminder':
        return DhanWiserColors.warning;
      case 'invitation':
      case 'server_invitation':
        return DhanWiserColors.primaryLight;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark
        ? DhanWiserColors.textPrimaryDark
        : DhanWiserColors.textPrimaryLight;
    final sub = isDark
        ? DhanWiserColors.textSecondaryDark
        : DhanWiserColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? DhanWiserColors.surfaceElevatedDark
                            : DhanWiserColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: text, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Activity',
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? DhanWiserColors.surfaceDark
                      : DhanWiserColors.gray100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: DhanWiserColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: sub,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_invitations.length}',
                                style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationsTab(isDark, text, sub),
                  _buildInvitationsTab(isDark, text, sub),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(bool isDark, Color text, Color sub) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProv, _) {
        if (notifProv.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: DhanWiserColors.primary),
          );
        }

        final notifications = notifProv.notifications;
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: DhanWiserColors.primary
                        .withValues(alpha: isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.notifications_rounded,
                      color: DhanWiserColors.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text('No activity yet',
                    style: GoogleFonts.inter(
                        fontSize: 17, fontWeight: FontWeight.w600, color: text)),
                const SizedBox(height: 4),
                Text('Your notifications will appear here',
                    style: GoogleFonts.inter(fontSize: 14, color: sub)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadNotifications,
          color: DhanWiserColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(
                notifications[index],
                isDark,
                text,
                sub,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInvitationsTab(bool isDark, Color text, Color sub) {
    if (_loadingInvitations) {
      return Center(
          child: CircularProgressIndicator(color: DhanWiserColors.primary));
    }

    if (_invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: DhanWiserColors.primaryLight
                    .withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.mail_outline_rounded,
                  color: DhanWiserColors.primaryLight, size: 28),
            ),
            const SizedBox(height: 16),
            Text('No invitations',
                style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w600, color: text)),
            const SizedBox(height: 4),
            Text('Group invitations will appear here',
                style: GoogleFonts.inter(fontSize: 14, color: sub)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: DhanWiserColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          return _buildInvitationItem(_invitations[index], isDark, text, sub);
        },
      ),
    );
  }

  Widget _buildInvitationItem(
      ServerInvitation invitation, bool isDark, Color text, Color sub) {
    final isResponding = _respondingIds.contains(invitation.id);
    final initial =
        invitation.serverName.isNotEmpty ? invitation.serverName[0].toUpperCase() : 'G';
    final time =
        invitation.createdAt != null ? _formatTime(invitation.createdAt!) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DhanWiserColors.primaryLight.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    colors: [
                      DhanWiserColors.primary,
                      DhanWiserColors.primaryLight
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.inter(
                        color: Colors.white,
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
                          color: text,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Invited by ${invitation.inviterName ?? invitation.inviterUsername}',
                      style: GoogleFonts.inter(fontSize: 13, color: sub),
                    ),
                  ],
                ),
              ),
              if (time.isNotEmpty)
                Text(time, style: GoogleFonts.inter(fontSize: 12, color: sub)),
            ],
          ),
          if (invitation.serverDescription != null &&
              invitation.serverDescription!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              invitation.serverDescription!,
              style: GoogleFonts.inter(fontSize: 13, color: sub, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: isResponding
                        ? null
                        : () => _respondToInvitation(invitation.id, 'reject'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: DhanWiserColors.coral.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: GoogleFonts.inter(
                        color: DhanWiserColors.coral,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: isResponding
                        ? null
                        : () => _respondToInvitation(invitation.id, 'accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DhanWiserColors.mint,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          DhanWiserColors.mint.withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isResponding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Accept & Join',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      AppNotification notification, bool isDark, Color text, Color sub) {
    final notifIcon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final time =
        notification.createdAt != null ? _formatTime(notification.createdAt!) : '';
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
          color: DhanWiserColors.coral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child:
            Icon(Icons.delete_outline_rounded, color: DhanWiserColors.coral, size: 22),
      ),
      onDismissed: (_) async {
        final notifProv =
            Provider.of<NotificationProvider>(context, listen: false);
        try {
          await NotificationService.deleteNotification(notification.id);
          notifProv.fetchNotifications();
        } catch (_) {}
      },
      child: GestureDetector(
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? DhanWiserColors.surfaceElevatedDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: notification.isRead
                ? null
                : Border.all(color: color.withValues(alpha: 0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
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
                      color: color.withValues(alpha: isDark ? 0.12 : 0.06),
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
                            fontWeight:
                                notification.isRead ? FontWeight.w400 : FontWeight.w500,
                            color: text,
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
                                      fontSize: 12, color: sub)),
                            if (notification.type == 'server_invitation' ||
                                notification.type == 'invitation' ||
                                notification.type == 'settlement_request') ...[
                              const SizedBox(width: 8),
                              Text(
                                isInvitationNotification
                                    ? 'Respond here or tap to view'
                                    : notification.type == 'settlement_request'
                                        ? 'Tap to review ->'
                                        : 'Tap to view ->',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: DhanWiserColors.primary,
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
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: isResponding
                              ? null
                              : () => _respondToInvitation(
                                    notification.relatedId!,
                                    'reject',
                                  ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: DhanWiserColors.coral.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: GoogleFonts.inter(
                              color: DhanWiserColors.coral,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: isResponding
                              ? null
                              : () => _respondToInvitation(
                                    notification.relatedId!,
                                    'accept',
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DhanWiserColors.mint,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                DhanWiserColors.mint.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                              : Text(
                                  'Accept',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
