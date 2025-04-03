import '../models/notification_model.dart';

class MockNotificationService {
  static List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: "Reminder: Don't Forget to Clock In!",
      message:
          'Hi,\nThis is a friendly reminder to clock in for your shift scheduled at [Start Time]. Please ensure you record your start time promptly.\nIf you\'ve already clocked in, kindly ignore this message',
      type: 'Reminder to Clock In/Out',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    NotificationModel(
      id: '2',
      title: 'Complete Your Clock-Out',
      message:
          'Hi,\nIt seems you haven\'t clocked out for your shift starting at [Start Time]. Please remember to clock out once your shift is complete.\nIf this was an oversight, you can log your clock-out time or submit a manual entry with a reason.',
      type: 'Reminder to Clock In/Out',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    NotificationModel(
      id: '3',
      title: 'New Appointment Scheduled',
      message:
          'You have a new appointment scheduled with Sarah Johnson for tomorrow at 2:00 PM. Please review the details and confirm your availability.',
      type: 'Appointment Update',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      id: '4',
      title: 'Schedule Change Alert',
      message:
          'Your shift on Friday has been modified. The new timing is from 9:00 AM to 5:00 PM. Please acknowledge this change.',
      type: 'Schedule Update',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '5',
      title: 'Timesheet Approval Required',
      message:
          'Your timesheet for last week is pending approval. Please review and submit it as soon as possible.',
      type: 'Timesheet',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  static List<NotificationModel> getUnreadNotifications() {
    return notifications.where((notification) => !notification.isRead).toList();
  }

  static List<NotificationModel> getAllNotifications() {
    return notifications;
  }

  static void markAsRead(String id) {
    final notification =
        notifications.firstWhere((notification) => notification.id == id);
    notification.isRead = true;
  }

  static void markAllAsRead() {
    for (var notification in notifications) {
      notification.isRead = true;
    }
  }
}
