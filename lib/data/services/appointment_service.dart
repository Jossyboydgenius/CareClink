import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/appointment_model.dart';
import 'api/api.dart';

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
} 