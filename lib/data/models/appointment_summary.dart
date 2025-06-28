class AppointmentSummary {
  final int completed;
  final String hours; // Changed to String to handle "0h 49m" format

  AppointmentSummary({
    required this.completed,
    required this.hours,
  });

  factory AppointmentSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentSummary(
      completed: json['completed'] ?? 0,
      hours: json['hours']?.toString() ??
          '0 hr', // Convert to String and provide default
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
