enum AppointmentStatus {
  none,
  pending,
  scheduled,
  completed,
  reschedule,
  inProgress,
}

class AppointmentModel {
  final String id;
  final String clientName;
  final String dateTime;
  final DateTime timestamp;
  final DateTime time;
  final DateTime endTime;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.dateTime,
    required this.timestamp,
    required this.status,
    required this.time,
    required this.endTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json,
      {String? userRole}) {
    final timestamp = DateTime.parse(json['date']);
    final time =
        json['time'] != null ? DateTime.parse(json['time']) : timestamp;
    final endTime = json['endTime'] != null
        ? DateTime.parse(json['endTime'])
        : DateTime(timestamp.year, timestamp.month, timestamp.day,
            timestamp.hour + 1, timestamp.minute);

    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12
        ? hour - 12
        : hour == 0
            ? 12
            : hour;

    final endHour = endTime.hour;
    final endMinute = endTime.minute;
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final endHour12 = endHour > 12
        ? endHour - 12
        : endHour == 0
            ? 12
            : endHour;

    // Format as "YYYY-MM-DD h:mm AM - h:mm PM"
    final dateTime =
        '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '$hour12:${minute.toString().padLeft(2, '0')} $period - $endHour12:${endMinute.toString().padLeft(2, '0')} $endPeriod';

    // Determine status based on user role
    String? statusValue;

    if (userRole == 'staff') {
      // For staff users, use staffStatus field
      statusValue = json['staffStatus'];
      print('Staff user - using staffStatus: $statusValue');
    } else {
      // For interpreter users, use interpreterStatus field
      statusValue = json['interpreterStatus'];
      print('Interpreter user - using interpreterStatus: $statusValue');
    }

    // Fallback to general status if role-specific status is not available
    if (statusValue == null || statusValue.isEmpty) {
      statusValue = json['status'];
      print('Using fallback status: $statusValue');
    }

    print('Final status value for parsing: $statusValue');

    return AppointmentModel(
      id: json['_id'] ?? '',
      clientName: json['client']?['fullname'] ?? '',
      dateTime: dateTime,
      timestamp: timestamp,
      time: time,
      endTime: endTime,
      status: _parseStatus(statusValue),
    );
  }

  static AppointmentStatus _parseStatus(String? status) {
    // Handle both staff status and interpreter status from the API
    // For staff users, we use 'staffStatus' field
    // For interpreter users, we use 'status' field
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'scheduled':
        return AppointmentStatus.scheduled;
      case 'completed':
        return AppointmentStatus.completed;
      case 'reschedule':
      case 'rescheduled': // Also handle 'rescheduled' variation
        return AppointmentStatus.reschedule;
      case 'in progress':
      case 'inprogress': // Also handle 'inprogress' variation (no space)
        return AppointmentStatus.inProgress;
      default:
        return AppointmentStatus.none;
    }
  }
}
