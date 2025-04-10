import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/locator.dart';
import '../../../../data/services/appointment_summary_service.dart';
import '../../../../app/navigation_state_manager.dart';
import '../../../../data/models/appointment_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _appointmentService = locator<AppointmentSummaryService>();
  final _stateManager = locator<NavigationStateManager>();

  // Cache for dashboard data
  SummaryCardData? _cachedDailySummary;
  SummaryCardData? _cachedWeeklySummary;
  SummaryCardData? _cachedMonthlySummary;
  AppointmentStatusSummary? _cachedStatusSummary;

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
    // If we have cached data and no forced refresh needed, use the cached data
    if (!event.forceRefresh &&
        !_stateManager.shouldRefreshDashboard() &&
        _cachedDailySummary != null) {
      emit(state.copyWith(
        isLoading: false,
        dailySummary: _cachedDailySummary,
        weeklySummary: _cachedWeeklySummary,
        monthlySummary: _cachedMonthlySummary,
        statusSummary: _cachedStatusSummary,
        error: null,
      ));
      return;
    }

    // Otherwise load fresh data
    emit(state.copyWith(isLoading: true));

    try {
      final daily = await _appointmentService.getDailySummary();
      final biWeekly = await _appointmentService.getBiWeeklySummary();
      final monthly = await _appointmentService.getMonthlySummary();
      final status = await _appointmentService.getStatusSummary();

      // Create formatted summary data
      _cachedDailySummary = daily != null
          ? SummaryCardData(
              hours: _formatHours(daily.hours),
              completed: _formatAppointments(daily.completed),
            )
          : null;

      _cachedWeeklySummary = biWeekly != null
          ? SummaryCardData(
              hours: _formatHours(biWeekly.hours),
              completed: _formatAppointments(biWeekly.completed),
            )
          : null;

      _cachedMonthlySummary = monthly != null
          ? SummaryCardData(
              hours: _formatHours(monthly.hours),
              completed: _formatAppointments(monthly.completed),
            )
          : null;

      _cachedStatusSummary = status;

      // Mark as refreshed
      _stateManager.markDashboardRefreshed();

      emit(state.copyWith(
        isLoading: false,
        dailySummary: _cachedDailySummary,
        weeklySummary: _cachedWeeklySummary,
        monthlySummary: _cachedMonthlySummary,
        statusSummary: _cachedStatusSummary,
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
