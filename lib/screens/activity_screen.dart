import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/notification_provider.dart';
import '../providers/server_provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'package:dhanwiser_fixed/theme/text_styles.dart';
import 'package:dhanwiser_fixed/widgets/bouncing_button.dart';

class ActivityScreen extends StatefulWidget {
  final bool isRootTab;
  const ActivityScreen({super.key, this.isRootTab = false});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Set<int> _respondingIds = {};

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
            content: Text(action == 'accept'
                ? 'Joined the group!'
                : 'Invitation declined'),
            backgroundColor: action == 'accept'
                ? DhanWiserColors.of(context).mint
                : DhanWiserColors.of(context).coral,
          ),
        );
        await notifProv.fetchNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: DhanWiserColors.of(context).coral,
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
        return Icons.flight_rounded; // Mock design uses flight for expense
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
        return Icons.group_add_rounded;
      case 'server_joined':
        return Icons.group_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColorForType(String type) {
    switch (type) {
      case 'expense_added':
        return DhanWiserColors.of(context).secondaryFixed;
      case 'settlement_requested':
      case 'settlement_request':
        return DhanWiserColors.of(context).warning;
      case 'settlement_approved':
        return DhanWiserColors.of(context).primaryContainer;
      case 'settlement_rejected':
      case 'payment_reminder':
        return DhanWiserColors.of(context).error;
      case 'invitation':
      case 'server_invitation':
        return DhanWiserColors.of(context).primary;
      case 'server_joined':
        return DhanWiserColors.of(context).teal;
      default:
        return DhanWiserColors.of(context).primary;
    }
  }

  Color _getIconBgColorForType(String type) {
    switch (type) {
      case 'expense_added':
        return DhanWiserColors.of(context).secondaryFixed.withValues(alpha: 0.1);
      case 'settlement_requested':
      case 'settlement_request':
        return DhanWiserColors.of(context).warning.withValues(alpha: 0.1);
      case 'settlement_approved':
        return DhanWiserColors.of(context).primaryContainer.withValues(alpha: 0.1);
      case 'settlement_rejected':
      case 'payment_reminder':
        return DhanWiserColors.of(context).error.withValues(alpha: 0.1);
      case 'invitation':
      case 'server_invitation':
        return DhanWiserColors.of(context).surfaceVariant;
      case 'server_joined':
        return DhanWiserColors.of(context).teal.withValues(alpha: 0.1);
      default:
        return DhanWiserColors.of(context).surfaceVariant;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DhanWiserColors.of(context).background,
      appBar: AppBar(
        backgroundColor: DhanWiserColors.of(context).background,
        elevation: 0,
        leading: widget.isRootTab ? null : PremiumIconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: DhanWiserColors.of(context).textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity',
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: DhanWiserColors.of(context).primary),
        ),
        centerTitle: true,
        actions: [
          PremiumIconButton(
            icon: Icon(Icons.notifications_outlined,
                color: DhanWiserColors.of(context).primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProv, _) {
          if (notifProv.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                  color: DhanWiserColors.of(context).primaryContainer),
            );
          }

          final notifications = notifProv.notifications;
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            color: DhanWiserColors.of(context).primaryContainer,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: notifications.length + 1, // +1 for skeleton
              itemBuilder: (context, index) {
                if (index == notifications.length) {
                  return _buildSkeletonLoader();
                }
                return _buildActivityItem(notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DhanWiserColors.of(context).primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined,
                color: DhanWiserColors.of(context).primaryContainer, size: 32),
          ),
          SizedBox(height: 16),
          Text(
            'No activity yet',
            style: DhanWiserTextStyles.buttonLarge(context)
                .copyWith(color: DhanWiserColors.of(context).textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'Your notifications will appear here',
            style: DhanWiserTextStyles.caption(context)
                .copyWith(color: DhanWiserColors.of(context).textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(AppNotification notification) {
    final notifIcon = _getIconForType(notification.type);
    final iconColor = _getIconColorForType(notification.type);
    final iconBgColor = _getIconBgColorForType(notification.type);
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: DhanWiserColors.of(context).error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: DhanWiserColors.of(context).error, size: 24),
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DhanWiserColors.of(context).card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.03),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
            border: !notification.isRead
                ? Border.all(color: iconColor.withValues(alpha: 0.2))
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(notifIcon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: DhanWiserTextStyles.bodyRegular(context).copyWith(
                          color: DhanWiserColors.of(context).onSurface, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (time.isNotEmpty && !isInvitationNotification) ...[
                      SizedBox(height: 4),
                      Text(
                        time,
                        style: DhanWiserTextStyles.caption(context)
                            .copyWith(color: DhanWiserColors.of(context).textSecondary),
                      ),
                    ],
                    if (isInvitationNotification) ...[
                      SizedBox(height: 16),
                      Row(
                        children: [
                          PremiumElevatedButton(
                            onPressed: isResponding
                                ? null
                                : () => _respondToInvitation(
                                    notification.relatedId!, 'accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DhanWiserColors.of(context).primaryContainer,
                              foregroundColor:
                                  DhanWiserColors.of(context).onPrimaryContainer,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child: isResponding
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            DhanWiserColors.of(context).onPrimaryContainer))
                                : Text(
                                    'Join',
                                    style:
                                        DhanWiserTextStyles.overline(context),
                                  ),
                          ),
                          SizedBox(width: 12),
                          PremiumOutlinedButton(
                            onPressed: isResponding
                                ? null
                                : () => _respondToInvitation(
                                    notification.relatedId!, 'reject'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: DhanWiserColors.of(context).surfaceVariant),
                              foregroundColor: DhanWiserColors.of(context).textSecondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                            ),
                            child: Text(
                              'Ignore',
                              style: DhanWiserTextStyles.overline(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (notification.amount != null) ...[
                SizedBox(width: 8),
                Text(
                  '${notification.amount! > 0 ? '+' : ''}\$${notification.amount!.abs().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: notification.amount! > 0
                          ? DhanWiserColors.of(context).primaryContainer
                          : (notification.type == 'payment_reminder'
                              ? DhanWiserColors.of(context).error
                              : DhanWiserColors.of(context).textPrimary)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DhanWiserColors.of(context).card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DhanWiserColors.of(context).surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.of(context).surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: DhanWiserColors.of(context).surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
