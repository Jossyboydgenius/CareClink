enum DurationStatus {
  clockIn,
  clockOut,
}

class TimesheetModel {
  final String id;
  final String clientName;
  final String clockIn;
  String? clockOut;
  String? duration;
  DurationStatus status;

  TimesheetModel({
    required this.id,
    required this.clientName,
    required this.clockIn,
    this.clockOut,
    this.duration,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'clockIn': clockIn,
      'clockOut': clockOut ?? '',
      'duration': duration ?? '',
      'status': status.toString().split('.').last.toLowerCase(),
    };
  }

  factory TimesheetModel.fromMap(Map<String, dynamic> map) {
    DurationStatus parseStatus(dynamic statusValue) {
      if (statusValue is DurationStatus) return statusValue;
      if (statusValue is String) {
        try {
          // Remove 'DurationStatus.' prefix if present
          final cleanStatus = statusValue.replaceAll('DurationStatus.', '');
          return DurationStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == cleanStatus.toLowerCase()
          );
        } catch (e) {
          // Default to clockIn if parsing fails
          return DurationStatus.clockIn;
        }
      }
      return DurationStatus.clockIn;
    }

    return TimesheetModel(
      id: map['id'] as String,
      clientName: map['clientName'] as String,
      clockIn: map['clockIn'] as String,
      clockOut: map['clockOut'] as String?,
      duration: map['duration'] as String?,
      status: parseStatus(map['status']),
    );
  }

  TimesheetModel copyWith({
    String? id,
    String? clientName,
    String? clockIn,
    String? clockOut,
    String? duration,
    DurationStatus? status,
  }) {
    return TimesheetModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }
} 