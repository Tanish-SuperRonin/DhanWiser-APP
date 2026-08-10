import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/cache_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Cache keys & TTLs
  static const String _notificationsKey = 'notifications_list';
  static const String _unreadCountKey = 'notifications_unread_count';
  static const Duration _notificationsTtl = Duration(minutes: 1);
  static const Duration _unreadCountTtl = Duration(seconds: 30);

  // Fetch notifications — serves cached data, refreshes in background.
  Future<void> fetchNotifications({bool unreadOnly = false}) async {
    final cacheKey =
        unreadOnly ? '${_notificationsKey}_unread' : _notificationsKey;

    // Check cache first
    final cached = CacheService.get<List<AppNotification>>(cacheKey);
    if (cached != null) {
      _notifications = cached;
      _isLoading = false;
      notifyListeners();

      // Background refresh
      _backgroundFetchNotifications(unreadOnly, cacheKey);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data =
          await NotificationService.getNotifications(unreadOnly: unreadOnly);
      _notifications = data['notifications'] as List<AppNotification>;
      _unreadCount = data['unreadCount'] as int;

      CacheService.put(cacheKey, _notifications, ttl: _notificationsTtl);
      CacheService.put(_unreadCountKey, _unreadCount, ttl: _unreadCountTtl);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// Background refresh for notifications.
  Future<void> _backgroundFetchNotifications(
      bool unreadOnly, String cacheKey) async {
    try {
      final data =
          await NotificationService.getNotifications(unreadOnly: unreadOnly);
      _notifications = data['notifications'] as List<AppNotification>;
      _unreadCount = data['unreadCount'] as int;

      CacheService.put(cacheKey, _notifications, ttl: _notificationsTtl);
      CacheService.put(_unreadCountKey, _unreadCount, ttl: _unreadCountTtl);
      notifyListeners();
    } catch (_) {}
  }

  // Fetch unread count only (lightweight) — cached with 30s TTL.
  Future<void> fetchUnreadCount() async {
    final cached = CacheService.get<int>(_unreadCountKey);
    if (cached != null) {
      _unreadCount = cached;
      notifyListeners();

      // Background refresh
      _backgroundFetchUnreadCount();
      return;
    }

    try {
      _unreadCount = await NotificationService.getUnreadCount();
      CacheService.put(_unreadCountKey, _unreadCount, ttl: _unreadCountTtl);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _backgroundFetchUnreadCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      _unreadCount = count;
      CacheService.put(_unreadCountKey, count, ttl: _unreadCountTtl);
      notifyListeners();
    } catch (_) {}
  }

  // Mark as read — invalidate cache.
  Future<void> markAsRead(int notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          relatedId: _notifications[index].relatedId,
          createdAt: _notifications[index].createdAt,
        );
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;

        // Update cache
        CacheService.put(_notificationsKey, _notifications,
            ttl: _notificationsTtl);
        CacheService.put(_unreadCountKey, _unreadCount, ttl: _unreadCountTtl);
        notifyListeners();
      }
    } catch (_) {}
  }

  // Mark all as read — invalidate cache.
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                message: n.message,
                isRead: true,
                relatedId: n.relatedId,
                createdAt: n.createdAt,
              ))
          .toList();
      _unreadCount = 0;

      // Update cache
      CacheService.put(_notificationsKey, _notifications,
          ttl: _notificationsTtl);
      CacheService.put(_unreadCountKey, 0, ttl: _unreadCountTtl);
      notifyListeners();
    } catch (_) {}
  }
}
