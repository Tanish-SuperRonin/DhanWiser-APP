import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/notification_provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final notifProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    await notifProvider.fetchNotifications();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expense_added': return Icons.receipt_long_rounded;
      case 'settlement_requested': return Icons.handshake_rounded;
      case 'settlement_approved': return Icons.check_circle_rounded;
      case 'settlement_rejected': return Icons.cancel_rounded;
      case 'server_invitation': return Icons.mail_rounded;
      case 'server_joined': return Icons.group_add_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'expense_added': return DhanWiserColors.primary;
      case 'settlement_requested': return DhanWiserColors.warning;
      case 'settlement_approved': return DhanWiserColors.mint;
      case 'settlement_rejected': return DhanWiserColors.coral;
      case 'server_invitation': return DhanWiserColors.primaryLight;
      case 'server_joined': return DhanWiserColors.teal;
      default: return DhanWiserColors.primary;
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
    final bg = isDark ? DhanWiserColors.backgroundDark : DhanWiserColors.backgroundLight;
    final text = isDark ? DhanWiserColors.textPrimaryDark : DhanWiserColors.textPrimaryLight;
    final sub = isDark ? DhanWiserColors.textSecondaryDark : DhanWiserColors.textSecondaryLight;

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

            // ── Notifications list ──
            Expanded(
              child: Consumer<NotificationProvider>(
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
                              color: DhanWiserColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.notifications_rounded, color: DhanWiserColors.primary, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text('No activity yet', style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w600, color: text)),
                          const SizedBox(height: 4),
                          Text('Your notifications will appear here', style: GoogleFonts.inter(
                            fontSize: 14, color: sub)),
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
                          notifications[index], isDark, text, sub,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
      AppNotification notification, bool isDark, Color text, Color sub) {
    final notifIcon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);
    final time = notification.createdAt != null
        ? _formatTime(notification.createdAt!)
        : '';

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
        child: Icon(Icons.delete_outline_rounded, color: DhanWiserColors.coral, size: 22),
      ),
      onDismissed: (_) async {
        final notifProv = Provider.of<NotificationProvider>(context, listen: false);
        try {
          await NotificationService.deleteNotification(notification.id);
          notifProv.fetchNotifications();
        } catch (_) {}
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji avatar
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
                      fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                      color: text,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: GoogleFonts.inter(fontSize: 12, color: sub),
                    ),
                  ],
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
      ),
    );
  }
}
