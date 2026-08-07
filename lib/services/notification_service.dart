import '../models/notification_model.dart';
import 'api_client.dart';

class NotificationService {
  // Get all notifications (paginated)
  static Future<Map<String, dynamic>> getNotifications({
    bool unreadOnly = false,
    int page = 1,
    int limit = 30,
  }) async {
    String endpoint = '/notifications?page=$page&limit=$limit';
    if (unreadOnly) endpoint += '&unreadOnly=true';
    final response = await ApiClient.get(endpoint);
    final data = response['data'];
    final notifications = (data['notifications'] as List<dynamic>)
        .map((n) => AppNotification.fromJson(n))
        .toList();

    // Extract pagination if available
    final pagination = data['pagination'] as Map<String, dynamic>?;

    return {
      'notifications': notifications,
      'unreadCount': data['unreadCount'] ?? 0,
      'totalCount': data['totalCount'] ?? notifications.length,
      'hasMore': pagination?['hasMore'] ?? false,
      'page': pagination?['page'] ?? page,
      'totalPages': pagination?['totalPages'] ?? 1,
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
