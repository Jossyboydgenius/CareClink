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

  // Factory constructor for creating a notification from FCM payload
  factory NotificationModel.fromFcm(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'New Notification',
      message: data['message'] ?? data['body'] ?? '',
      type: data['type'] ?? 'General',
      timestamp: DateTime.now(),
    );
  }
}
