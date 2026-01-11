import '../../../models/notification.dart';

abstract class NotificationsRepository {
  /// Stream of notifications for a specific user
  Stream<List<AppNotification>> watchNotifications(String userId);

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId);

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);
}
