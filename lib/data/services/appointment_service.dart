import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/appointment_model.dart';
import 'api/api.dart';
import 'api/api_response.dart';
import 'user_service.dart';
import 'signature_service.dart';

class AppointmentService {
  final Api _api = locator<Api>();
  final UserService _userService = locator<UserService>();
  final SignatureService _signatureService = locator<SignatureService>();

  /// Upload signature for appointment
  Future<ApiResponse> uploadSignature({
    required String appointmentId,
    required Uint8List signatureBytes,
  }) async {
    return await _signatureService.uploadSignatureToAppointment(
      appointmentId: appointmentId,
      signatureBytes: signatureBytes,
    );
  }

  // Method to get today's appointments
  Future<List<AppointmentModel>> getTodayAppointments() async {
    try {
      // Get current user role to properly parse status
      final currentUser = await _userService.getCurrentUser();
      final userRole = currentUser['role'] ?? 'interpreter';

      debugPrint('Getting appointments for user role: $userRole');

      final response = await _api.getData(
        '/user-appointment/today',
        hasHeader: true,
      );

      if (response.isSuccessful && response.data != null) {
        final List<dynamic> appointments = response.data['appointments'];
        return appointments
            .map((appointment) =>
                AppointmentModel.fromJson(appointment, userRole: userRole))
            .toList();
      }

      debugPrint('Error getting today\'s appointments: ${response.message}');
      return [];
    } catch (e) {
      debugPrint('Error getting today\'s appointments: $e');
      return [];
    }
  }

  // For backward compatibility - calls getTodayAppointments
  Future<List<AppointmentModel>> getAppointments() async {
    debugPrint('getAppointments called - using getTodayAppointments instead');
    return getTodayAppointments();
  }

  Future<ApiResponse> clockIn({
    required String appointmentId,
    required DateTime date,
  }) async {
    try {
      final response = await _api.postData(
        '/user-appointment/check-in/$appointmentId',
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
      // Format date as YYYY-MM-DD
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Format clockIn as ISO string
      final clockInStr = clockIn.toIso8601String();

      debugPrint(
          'Manual clock in request - appointmentId: $appointmentId, date: $dateStr, clockIn: $clockInStr, reason: $reason');

      final response = await _api.postData(
        '/user-appointment/manual-checkin/$appointmentId',
        {
          'date': dateStr,
          'clockIn': clockInStr,
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
