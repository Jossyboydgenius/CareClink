class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  static List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: "Reminder: Don't Forget to Clock In!",
      message: 'Hi,\nThis is a friendly reminder to clock in for your shift scheduled at [Start Time]. Please ensure you record your start time promptly.\nIf you\'ve already clocked in, kindly ignore this message',
      type: 'Reminder to Clock In/Out',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    NotificationModel(
      id: '2',
      title: 'Complete Your Clock-Out',
      message: 'Hi,\nIt seems you haven\'t clocked out for your shift starting at [Start Time]. Please remember to clock out once your shift is complete.\nIf this was an oversight, you can log your clock-out time or submit a manual entry with a reason.',
      type: 'Reminder to Clock In/Out',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  static List<NotificationModel> getUnreadNotifications() {
    return notifications.where((notification) => !notification.isRead).toList();
  }

  static List<NotificationModel> getAllNotifications() {
    return notifications;
  }

  static void markAsRead(String id) {
    final notification = notifications.firstWhere((notification) => notification.id == id);
    notification.isRead = true;
  }

  static void markAllAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
  }
} 