import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/appointment_model.dart';
import 'api/api.dart';
import 'api/api_response.dart';
import 'local_storage_service.dart';

class AppointmentService {
  final Api _api = locator<Api>();

  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await _api.getData(
        '/user-appointment/appointments',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        final List<dynamic> appointments = response.data['appointments'];
        return appointments
            .map((appointment) => AppointmentModel.fromJson(appointment))
            .toList();
      }

      debugPrint('Error getting appointments: ${response.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting appointments: $e');
      return [];
    }
  }

  Future<ApiResponse> clockIn({
    required String appointmentId,
    required DateTime date,
  }) async {
    try {
      final response = await _api.postData(
        '/interpreter/check-in/$appointmentId',
        {
          'date': date.toIso8601String(),
        },
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('Clock in successful: ${response.data}');
      } else {
        debugPrint('Clock in failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Error during clock in: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Failed to clock in: $e',
      );
    }
  }

  Future<ApiResponse> manualClockIn({
    required String appointmentId,
    required DateTime date,
    required DateTime clockIn,
    required String reason,
  }) async {
    try {
      final response = await _api.postData(
        '/interpreter/manual-checkin/$appointmentId',
        {
          'date': date.toIso8601String(),
          'clockIn': clockIn.toIso8601String(),
          'reason': reason,
        },
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('Manual clock in successful: ${response.data}');
      } else {
        debugPrint('Manual clock in failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Error during manual clock in: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Failed to manual clock in: $e',
      );
    }
  }
} 