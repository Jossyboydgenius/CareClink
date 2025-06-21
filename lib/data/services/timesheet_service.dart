import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import 'api/api.dart';
import 'api/api_response.dart';

class TimesheetService {
  static final TimesheetService _instance = TimesheetService._internal();
  factory TimesheetService() => _instance;
  TimesheetService._internal();

  final List<Map<String, dynamic>> _recentTimesheets = [];
  final Api _api = locator<Api>();

  List<Map<String, dynamic>> get recentTimesheets => _recentTimesheets;

  String formatTimeFromISO(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return isoTime;
    }
  }

  Map<String, dynamic>? getTimesheet(String id) {
    try {
      return _recentTimesheets.firstWhere((timesheet) => timesheet['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void addTimesheet(Map<String, dynamic> timesheet) {
    final formattedTimesheet = {
      ...timesheet,
      'clockIn': formatTimeFromISO(timesheet['clockIn']),
      'clockOut': formatTimeFromISO(timesheet['clockOut']),
    };
    _recentTimesheets.insert(0, formattedTimesheet);
  }

  void updateTimesheet(String id, Map<String, dynamic> updatedTimesheet) {
    final formattedTimesheet = {
      ...updatedTimesheet,
      'clockIn': formatTimeFromISO(updatedTimesheet['clockIn']),
      'clockOut': formatTimeFromISO(updatedTimesheet['clockOut']),
    };
    final index =
        _recentTimesheets.indexWhere((timesheet) => timesheet['id'] == id);
    if (index != -1) {
      _recentTimesheets[index] = formattedTimesheet;
    }
  }

  void clearTimesheets() {
    _recentTimesheets.clear();
  }

  Future<ApiResponse> getTimesheets() async {
    try {
      final response = await _api.getData(
        '/user-appointment/recent-timesheet',
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('Timesheets fetched successfully: ${response.data}');
      } else {
        debugPrint('Failed to fetch timesheets: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Error fetching timesheets: $e');
      return ApiResponse(
        isSuccessful: false,
        message: 'Failed to fetch timesheets: $e',
      );
    }
  }

  // Process timesheet data from API response
  void processTimesheetsFromResponse(List<dynamic> timesheets) {
    clearTimesheets();

    for (int i = 0; i < timesheets.length; i++) {
      final timesheet = timesheets[i];

      // Get client name from nested client object
      String clientName = 'Unknown Client';
      final clientData = timesheet['client'];
      if (clientData != null && clientData is Map) {
        clientName = clientData['fullname']?.toString() ?? 'Unknown Client';
      }

      // Determine which clock times to use - support both formats
      String? clockIn = timesheet['clockIn']?.toString();
      clockIn ??= timesheet['clockInStaff']?.toString();

      String? clockOut = timesheet['clockOut']?.toString();
      clockOut ??= timesheet['clockOutStaff']?.toString();

      // Determine status - use the specific status for the role when available
      String status;
      if (timesheet['status'] != null) {
        status = timesheet['status'].toString().toLowerCase();
      } else if (timesheet['staffStatus'] != null) {
        status = timesheet['staffStatus'].toString().toLowerCase();
      } else {
        // Fallback based on clockOut
        status =
            (clockOut == null || clockOut == 'null') ? 'clockin' : 'completed';
      }

      // Get duration - support both formats
      String duration = '0';
      if (timesheet['duration'] != null) {
        duration = timesheet['duration'].toString();
      } else if (timesheet['durationStaff'] != null) {
        duration = timesheet['durationStaff'].toString();
      }

      // Build the timesheet object with correct data
      addTimesheet({
        'id': timesheet['_id'],
        'clientName': clientName,
        'clockIn': clockIn,
        'clockOut': clockOut,
        'duration': duration,
        'status': status,
      });
    }
  }

  Future<ApiResponse> clockOut(String timesheetId, {String reason = ''}) async {
    try {
      final response = await _api.putData(
        '/user-appointment/check-out/$timesheetId',
        {
          'reason': reason,
        },
      );

      if (response.isSuccessful) {
        // Use a microtask to allow UI to update before fetching timesheets
        Future.microtask(() async {
          // Fetch updated timesheets from backend
          final timesheetsResponse = await getTimesheets();
          if (timesheetsResponse.isSuccessful &&
              timesheetsResponse.data != null) {
            final timesheets = timesheetsResponse.data['timesheets'] as List;
            // Process timesheets using the helper method
            processTimesheetsFromResponse(timesheets);
          }
        });
      }

      return response;
    } catch (e) {
      debugPrint('Error clocking out: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'Failed to clock out',
      );
    }
  }

  // Method for manual clock out
  Future<ApiResponse> manualClockOut(
      String timesheetId, DateTime clockOutTime, String reason) async {
    try {
      // Format clockOut as ISO string
      final clockOutStr = clockOutTime.toIso8601String();

      debugPrint(
          'Manual clock out request - timesheetId: $timesheetId, clockOut: $clockOutStr, reason: $reason');

      final response = await _api.putData(
        '/user-appointment/manual-checkout/$timesheetId',
        {
          'clockOut': clockOutStr,
          'reason': reason,
        },
      );

      if (response.isSuccessful) {
        debugPrint('Manual clock out successful: ${response.data}');

        // Refresh the timesheet list same as regular clock out
        Future.microtask(() async {
          final timesheetsResponse = await getTimesheets();
          if (timesheetsResponse.isSuccessful &&
              timesheetsResponse.data != null) {
            final timesheets = timesheetsResponse.data['timesheets'] as List;
            // Process timesheets using the helper method
            processTimesheetsFromResponse(timesheets);
          }
        });
      } else {
        debugPrint('Manual clock out failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Error during manual clock out: $e');
      return ApiResponse(
        data: null,
        isSuccessful: false,
        message: 'Failed to manually clock out: $e',
      );
    }
  }

  // List of predefined clock-out reasons
  List<String> getClockOutReasons() {
    return [
      'Appointment completed',
      'Patient not available',
      'Technical issues',
      'Staff request',
      'Emergency',
      'Other',
    ];
  }
}
