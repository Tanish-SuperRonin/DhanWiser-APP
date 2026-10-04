import 'package:flutter/material.dart';
import '../theme/iconly_icons.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../providers/notification_provider.dart';
import '../providers/server_provider.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/backend_connection_view.dart';

class ActivityScreen extends StatefulWidget {
  final bool isRootTab;
  const ActivityScreen({super.key, this.isRootTab = false});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Set<int> _respondingIds = {};
  String _selectedFilter = 'All';

  final List<String> _filterTabs = ['All', 'Requests', 'Expenses', 'Circles'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notifProvider.fetchNotifications();
  }

  Future<void> _respondToInvitation(int invitationId, String action) async {
    setState(() => _respondingIds.add(invitationId));
    try {
      final serverProv = Provider.of<ServerProvider>(context, listen: false);
      final notifProv = Provider.of<NotificationProvider>(context, listen: false);
      await serverProv.respondToInvitation(invitationId, action);
      if (mounted) {
        final colors = DhanWiserColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'accept' ? 'Joined circle successfully!' : 'Invitation declined'),
            backgroundColor: action == 'accept' ? colors.emerald : colors.carmine,
          ),
        );
        await notifProv.fetchNotifications();
      }
    } catch (e) {
      if (mounted) {
        final colors = DhanWiserColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: colors.carmine,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _respondingIds.remove(invitationId));
    }
  }

  Future<void> _markAllAsRead() async {
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);
    try {
      await NotificationService.markAllAsRead();
      await notifProv.fetchNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All marked as read'),
            backgroundColor: DhanWiserColors.of(context).emerald,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'expense_added':
        return IconlyBold.document;
      case 'settlement_requested':
      case 'settlement_request':
        return IconlyBold.swap;
      case 'settlement_approved':
        return IconlyBold.shieldDone;
      case 'settlement_rejected':
        return IconlyBold.shieldFail;
      case 'payment_reminder':
        return IconlyBold.notification;
      case 'invitation':
      case 'server_invitation':
        return IconlyBold.addUser;
      case 'server_joined':
        return IconlyBold.user2;
      default:
        return IconlyBold.activity;
    }
  }

  Color _getIconColorForType(String type, DhanWiserColors colors) {
    switch (type) {
      case 'expense_added':
        return colors.primary;
      case 'settlement_requested':
      case 'settlement_request':
        return colors.warning;
      case 'settlement_approved':
        return colors.emerald;
      case 'settlement_rejected':
      case 'payment_reminder':
        return colors.carmine;
      case 'invitation':
      case 'server_invitation':
        return colors.secondary;
      case 'server_joined':
        return colors.teal;
      default:
        return colors.primary;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }

  List<AppNotification> _filterNotifications(List<AppNotification> notifications) {
    if (_selectedFilter == 'All') return notifications;
    if (_selectedFilter == 'Requests') {
      return notifications
          .where((n) =>
              n.type.contains('settlement') ||
              n.type.contains('reminder'))
          .toList();
    }
    if (_selectedFilter == 'Expenses') {
      return notifications.where((n) => n.type.contains('expense')).toList();
    }
    if (_selectedFilter == 'Circles') {
      return notifications
          .where((n) => n.type.contains('invitation') || n.type.contains('server'))
          .toList();
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final colors = DhanWiserColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: widget.isRootTab
            ? null
            : PremiumIconButton(
                icon: Icon(IconlyLight.arrowLeft2, color: colors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Activity',
          style: DhanWiserTextStyles.title2(context).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notifProv, _) {
              final hasUnread = notifProv.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: _markAllAsRead,
                child: Text(
                  'Read All',
                  style: DhanWiserTextStyles.overline(context).copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notifProv, _) {
          if (notifProv.isLoading && notifProv.notifications.isEmpty) {
            return BackendConnectionView(
              title: 'Loading activity...',
              onRetry: notifProv.fetchNotifications,
            );
          }

          final allNotifs = notifProv.notifications;
          final filtered = _filterNotifications(allNotifs);

          return Column(
            children: [
              // Filter Chips Row
              _buildFilterChips(colors, isDark),
              const SizedBox(height: 8),

              // Activity List or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(colors)
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: colors.primary,
                        backgroundColor: colors.card,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(filtered[index], colors, isDark);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Filter Chips Row
  Widget _buildFilterChips(DhanWiserColors colors, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: _filterTabs.map((tab) {
          final isSelected = _selectedFilter == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BouncingButton(
              onTap: () => setState(() => _selectedFilter = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? colors.primary : const Color(0xFF0F172A))
                      : colors.card,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : colors.cardBorder,
                  ),
                ),
                child: Text(
                  tab,
                  style: DhanWiserTextStyles.overline(context).copyWith(
                    color: isSelected
                        ? (isDark ? colors.background : Colors.white)
                        : colors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Modern Empty State
  Widget _buildEmptyState(DhanWiserColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.card,
                shape: BoxShape.circle,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Center(
                child: Icon(
                  IconlyLight.activity,
                  color: colors.textDisabled,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Activity in "$_selectedFilter"',
              style: DhanWiserTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New group expenses, settlement requests, and notifications will be logged here in real-time.',
              textAlign: TextAlign.center,
              style: DhanWiserTextStyles.caption(context).copyWith(
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Activity Card Widget
  Widget _buildActivityCard(AppNotification notification, DhanWiserColors colors, bool isDark) {
    final icon = _getIconForType(notification.type);
    final iconColor = _getIconColorForType(notification.type, colors);
    final time = notification.createdAt != null ? _formatTime(notification.createdAt!) : '';

    final isInvitation = (notification.type == 'server_invitation' ||
            notification.type == 'invitation') &&
        notification.relatedId != null;
    final isResponding = isInvitation && _respondingIds.contains(notification.relatedId!);

    return Dismissible(
      key: Key('activity_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.carmine.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.carmine.withValues(alpha: 0.3)),
        ),
        child: Icon(IconlyLight.delete, color: colors.carmine, size: 22),
      ),
      onDismissed: (_) async {
        final notifProv = Provider.of<NotificationProvider>(context, listen: false);
        try {
          await NotificationService.deleteNotification(notification.id);
          notifProv.fetchNotifications();
        } catch (_) {}
      },
      child: GestureDetector(
        onTap: () async {
          if (!notification.isRead) {
            await NotificationService.markAsRead(notification.id);
            if (mounted) {
              Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
            }
          }
          if (notification.type == 'settlement_request' &&
              notification.relatedId != null &&
              mounted) {
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
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: !notification.isRead
                  ? (isDark ? colors.primary.withValues(alpha: 0.4) : const Color(0xFF0F172A).withValues(alpha: 0.25))
                  : colors.cardBorder,
              width: 1.0,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Avatar
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                  ),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.card, width: 1.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // Title and message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.isNotEmpty ? notification.title : 'Update',
                            style: DhanWiserTextStyles.bodyBold(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (time.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: DhanWiserTextStyles.caption(context).copyWith(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.message,
                      style: DhanWiserTextStyles.caption(context).copyWith(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Amount pill if available
                    if (notification.amount != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (notification.amount! >= 0 ? colors.emerald : colors.carmine)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          CurrencyFormatter.format(notification.amount!.abs()),
                          style: DhanWiserTextStyles.caption(context).copyWith(
                            color: notification.amount! >= 0 ? colors.emerald : colors.carmine,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],

                    // Accept / Decline Buttons for Circle Invites
                    if (isInvitation) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          BouncingButton(
                            onTap: isResponding
                                ? null
                                : () => _respondToInvitation(notification.relatedId!, 'accept'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? colors.primary : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: isResponding
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark ? colors.background : Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Join Circle',
                                      style: DhanWiserTextStyles.overline(context).copyWith(
                                        color: isDark ? colors.background : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BouncingButton(
                            onTap: isResponding
                                ? null
                                : () => _respondToInvitation(notification.relatedId!, 'reject'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainer,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Text(
                                'Decline',
                                style: DhanWiserTextStyles.overline(context).copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}
