import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  // Get all notifications
  static Future<Map<String, dynamic>> getNotifications(
      {bool unreadOnly = false}) async {
    String endpoint = '/notifications';
    if (unreadOnly) endpoint += '?unreadOnly=true';
    final response = await ApiClient.get(endpoint);
    final data = response['data'];
    final notifications = (data['notifications'] as List<dynamic>)
        .map((n) => AppNotification.fromJson(n))
        .toList();
    return {
      'notifications': notifications,
      'unreadCount': data['unreadCount'] ?? 0,
      'totalCount': data['totalCount'] ?? 0,
    };
  }

  // Get unread count
  static Future<int> getUnreadCount() async {
    final response = await ApiClient.get('/notifications/unread-count');
    return response['data']['unreadCount'] ?? 0;
  }

  // Mark notification as read
  static Future<void> markAsRead(int notificationId) async {
    await ApiClient.post('/notifications/$notificationId/read');
  }

  // Mark all as read
  static Future<void> markAllAsRead() async {
    await ApiClient.post('/notifications/read-all');
  }

  // Delete a notification
  static Future<void> deleteNotification(int notificationId) async {
    await ApiClient.delete('/notifications/$notificationId');
  }
}
