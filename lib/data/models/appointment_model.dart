enum AppointmentStatus {
  none,
  pending,
  scheduled,
  completed,
  reschedule,
}

class AppointmentModel {
  final String id;
  final String clientName;
  final String dateTime;
  final DateTime timestamp;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.dateTime,
    required this.timestamp,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json['date']);
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    final endHour12 = (hour12 + 1) > 12 ? 1 : hour12 + 1;
    final dateTime = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '$hour12:${minute.toString().padLeft(2, '0')} - $endHour12:${minute.toString().padLeft(2, '0')} $period';

    return AppointmentModel(
      id: json['_id'] ?? '',
      clientName: json['client']?['fullname'] ?? '',
      dateTime: dateTime,
      timestamp: timestamp,
      status: _parseStatus(json['status']),
    );
  }

  static AppointmentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'reschedule':
        return AppointmentStatus.reschedule;
      default:
        return AppointmentStatus.none;
    }
  }
} 