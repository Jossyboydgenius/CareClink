import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/appointment_summary.dart';
import '../services/api/api.dart';

class AppointmentSummaryService {
  final Api _api = locator<Api>();

  Future<AppointmentSummary?> getDailySummary() async {
    try {
      final response = await _api.getData(
        '/appointment-summary/daily',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        return AppointmentSummary.fromJson(response.data);
      }
      debugPrint('Error getting daily summary: ${response.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting daily summary: $e');
      return null;
    }
  }

  Future<AppointmentSummary?> getBiWeeklySummary() async {
    try {
      final response = await _api.getData(
        '/appointment-summary/bi-weekly',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        return AppointmentSummary.fromJson(response.data);
      }
      debugPrint('Error getting bi-weekly summary: ${response.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting bi-weekly summary: $e');
      return null;
    }
  }

  Future<AppointmentSummary?> getMonthlySummary() async {
    try {
      final response = await _api.getData(
        '/appointment-summary/monthly',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        return AppointmentSummary.fromJson(response.data);
      }
      debugPrint('Error getting monthly summary: ${response.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting monthly summary: $e');
      return null;
    }
  }

  Future<AppointmentStatusSummary?> getStatusSummary() async {
    try {
      final response = await _api.getData(
        '/appointment-summary/status-summary',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        return AppointmentStatusSummary.fromJson(response.data);
      }
      debugPrint('Error getting status summary: ${response.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting status summary: $e');
      return null;
    }
  }
} 