class AppointmentSummary {
  final int completed;
  final int hours;

  AppointmentSummary({
    required this.completed,
    required this.hours,
  });

  factory AppointmentSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentSummary(
      completed: json['completed'] ?? 0,
      hours: json['hours'] ?? 0,
    );
  }
}

class AppointmentStatusSummary {
  final int pending;
  final String completed;

  AppointmentStatusSummary({
    required this.pending,
    required this.completed,
  });

  factory AppointmentStatusSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentStatusSummary(
      pending: json['pending'] ?? 0,
      completed: json['completed'] ?? '0 / 0',
    );
  }
} 