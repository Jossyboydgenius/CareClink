import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/locator.dart';
import '../../../../data/services/appointment_summary_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _appointmentService = locator<AppointmentSummaryService>();

  DashboardBloc() : super(const DashboardState()) {
    on<LoadDashboardSummaries>(_onLoadDashboardSummaries);
  }

  String _formatHours(int hours) {
    return '$hours ${hours <= 1 ? 'hr' : 'hrs'}';
  }

  String _formatAppointments(int count) {
    return '$count ${count == 1 ? 'appointment' : 'appointments'}';
  }

  Future<void> _onLoadDashboardSummaries(
    LoadDashboardSummaries event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final daily = await _appointmentService.getDailySummary();
      final biWeekly = await _appointmentService.getBiWeeklySummary();
      final monthly = await _appointmentService.getMonthlySummary();
      final status = await _appointmentService.getStatusSummary();

      emit(state.copyWith(
        isLoading: false,
        dailySummary: daily != null
            ? SummaryCardData(
                hours: _formatHours(daily.hours),
                completed: _formatAppointments(daily.completed),
              )
            : null,
        weeklySummary: biWeekly != null
            ? SummaryCardData(
                hours: _formatHours(biWeekly.hours),
                completed: _formatAppointments(biWeekly.completed),
              )
            : null,
        monthlySummary: monthly != null
            ? SummaryCardData(
                hours: _formatHours(monthly.hours),
                completed: _formatAppointments(monthly.completed),
              )
            : null,
        statusSummary: status,
        error: null,
      ));
    } catch (e) {
      debugPrint('Error loading dashboard summaries: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data',
      ));
    }
  }
} 