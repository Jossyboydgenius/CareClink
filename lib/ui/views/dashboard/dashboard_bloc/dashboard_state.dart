import '../../../../data/models/appointment_summary.dart';

class SummaryCardData {
  final String hours;
  final String completed;

  const SummaryCardData({
    required this.hours,
    required this.completed,
  });
}

class DashboardState {
  final bool isLoading;
  final String? error;
  final SummaryCardData? dailySummary;
  final SummaryCardData? weeklySummary;
  final SummaryCardData? monthlySummary;
  final AppointmentStatusSummary? statusSummary;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.dailySummary,
    this.weeklySummary,
    this.monthlySummary,
    this.statusSummary,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    SummaryCardData? dailySummary,
    SummaryCardData? weeklySummary,
    SummaryCardData? monthlySummary,
    AppointmentStatusSummary? statusSummary,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      dailySummary: dailySummary ?? this.dailySummary,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      statusSummary: statusSummary ?? this.statusSummary,
    );
  }
} 