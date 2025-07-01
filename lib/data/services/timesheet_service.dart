import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../utils/timesheet_helper.dart';
import 'api/api.dart';
import 'api/api_response.dart';
import 'user_service.dart';

class TimesheetService {
  static final TimesheetService _instance = TimesheetService._internal();
  factory TimesheetService() => _instance;
  TimesheetService._internal();

  final List<Map<String, dynamic>> _recentTimesheets = [];
  final Api _api = locator<Api>();
  final UserService _userService = locator<UserService>();

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
    // Debug the incoming data
    debugPrint('=== addTimesheet called ===');
    debugPrint('Incoming timesheet data: $timesheet');

    // Format clock times
    final String formattedClockIn = formatTimeFromISO(timesheet['clockIn']);
    final String? rawClockOut = timesheet['clockOut']?.toString();
    final String formattedClockOut = formatTimeFromISO(rawClockOut);

    // Log the timesheet data for debugging
    debugPrint(
        'Adding timesheet: ${timesheet['id']}, rawClockOut=$rawClockOut, formatted=$formattedClockOut');
    debugPrint('Incoming status: ${timesheet['status']}');

    // Use TimesheetHelper to ensure status is consistent and correct
    // Pass the raw clockOut value for proper validation, not the formatted time
    String status = TimesheetHelper.determineTimesheetStatus(
        rawStatus: timesheet['status'],
        clockOut: rawClockOut, // Use raw value here for proper detection
        defaultStatus: 'clockin');

    final formattedTimesheet = {
      ...timesheet,
      'clockIn': formattedClockIn,
      'clockOut': formattedClockOut,
      'status': status, // Use our corrected status
      'rawClockOut': rawClockOut, // Keep raw value for helper functions
    };

    debugPrint('Final timesheet data: $formattedTimesheet');
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
  Future<void> processTimesheetsFromResponse(List<dynamic> timesheets) async {
    clearTimesheets();

    // Get current user role to determine which fields to use
    final currentUser = await _userService.getCurrentUser();
    final userRole = currentUser['role'] ?? 'interpreter';

    debugPrint('Processing timesheets for user role: $userRole');
    debugPrint('Current user data: $currentUser');
    debugPrint('Total timesheets to process: ${timesheets.length}');

    // Log the raw API response data for debugging
    for (int i = 0; i < timesheets.length; i++) {
      debugPrint('=== RAW TIMESHEET $i ===');
      debugPrint('Raw timesheet data: ${timesheets[i]}');
    }

    for (int i = 0; i < timesheets.length; i++) {
      final timesheet = timesheets[i];

      // Get client name from nested client object
      String clientName = 'Unknown Client';
      final clientData = timesheet['client'];
      if (clientData != null && clientData is Map) {
        clientName = clientData['fullname']?.toString() ?? 'Unknown Client';
      }

      // Determine which clock times and status to use based on user role
      String? clockIn;
      String? clockOut;
      String? status;

      // Debug: Print the raw timesheet data for this specific timesheet
      debugPrint('Processing timesheet ${timesheet['_id']}:');
      debugPrint('  clockInInterpreter: ${timesheet['clockInInterpreter']}');
      debugPrint('  clockOutInterpreter: ${timesheet['clockOutInterpreter']}');
      debugPrint('  interpreterStatus: ${timesheet['interpreterStatus']}');
      debugPrint('  clockInStaff: ${timesheet['clockInStaff']}');
      debugPrint('  clockOutStaff: ${timesheet['clockOutStaff']}');
      debugPrint('  staffStatus: ${timesheet['staffStatus']}');

      if (userRole == 'staff') {
        // For staff users, use staff-specific fields
        clockIn = timesheet['clockInStaff']?.toString();
        clockOut = timesheet['clockOutStaff']?.toString();
        status = timesheet['staffStatus']?.toString();
        debugPrint(
            '  Using STAFF fields: clockIn=$clockIn, clockOut=$clockOut, status=$status');
      } else {
        // For interpreter users, use interpreter-specific fields
        clockIn = timesheet['clockInInterpreter']?.toString();
        clockOut = timesheet['clockOutInterpreter']?.toString();
        status = timesheet['interpreterStatus']?.toString();
        debugPrint(
            '  Using INTERPRETER fields: clockIn=$clockIn, clockOut=$clockOut, status=$status');
      }

      // Fallback to generic fields if role-specific fields are not available
      clockIn ??= timesheet['clockIn']?.toString();
      clockOut ??= timesheet['clockOut']?.toString();
      status ??= timesheet['status']?.toString();

      debugPrint(
          '  Final values after fallback: clockIn=$clockIn, clockOut=$clockOut, status=$status');

      // Determine final status using our helper class for consistency
      final String finalStatus = TimesheetHelper.determineTimesheetStatus(
        rawStatus: status,
        clockOut: clockOut,
      );

      debugPrint('  Computed finalStatus: $finalStatus');

      // Get duration - use role-specific duration
      String duration = '0';
      if (userRole == 'staff') {
        duration = timesheet['durationStaff']?.toString() ?? '0';
      } else {
        duration = timesheet['durationInterpreter']?.toString() ?? '0';
      }

      // Fallback to generic duration
      if (duration == '0') {
        duration = timesheet['duration']?.toString() ?? '0';
      }

      // Build the timesheet object with correct data
      debugPrint('  About to call addTimesheet with clockOut: $clockOut');
      addTimesheet({
        'id': timesheet['_id'],
        'clientName': clientName,
        'clockIn': clockIn,
        'clockOut': clockOut,
        'duration': duration,
        'status':
            status, // Pass raw status, let addTimesheet compute final status
      });
    }
  }

  Future<ApiResponse> clockOut(String timesheetId, {String reason = ''}) async {
    try {
      debugPrint('Clocking out timesheet: $timesheetId');

      // Add timestamp to ensure the API has the current time
      final now = DateTime.now();
      final clockOutTime = now.toIso8601String();

      // Log the exact API call for debugging
      debugPrint('API call: PUT /user-appointment/check-out/$timesheetId');
      debugPrint(
          'Request body: {"reason": "$reason", "clockOut": "$clockOutTime"}');

      final response = await _api.putData(
        '/user-appointment/check-out/$timesheetId',
        {
          'reason': reason,
          'clockOut': clockOutTime, // Add the current time explicitly
        },
      );

      // Log the response for debugging
      debugPrint(
          'API response: isSuccessful=${response.isSuccessful}, message=${response.message}');

      if (response.isSuccessful) {
        // Log the successful clock out
        debugPrint(
            'Successfully clocked out timesheet: $timesheetId, server response: ${response.data}');

        // Update timesheet status locally before API refresh
        final int index =
            _recentTimesheets.indexWhere((ts) => ts['id'] == timesheetId);
        if (index != -1) {
          // Get current timestamp to use consistently
          final String timestamp = DateTime.now().toIso8601String();
          debugPrint(
              'Updating local timesheet data: index=$index, new status=clockout, clockOut=$timestamp');

          _recentTimesheets[index]['status'] = 'clockout';
          _recentTimesheets[index]['clockOut'] = timestamp;
        } else {
          debugPrint(
              'Warning: Could not find timesheet with ID $timesheetId in local cache');
        }

        // Use a microtask to allow UI to update before fetching timesheets
        Future.microtask(() async {
          // Fetch updated timesheets from backend
          final timesheetsResponse = await getTimesheets();
          if (timesheetsResponse.isSuccessful &&
              timesheetsResponse.data != null) {
            final timesheets = timesheetsResponse.data['timesheets'] as List;
            // Process timesheets using the helper method
            await processTimesheetsFromResponse(timesheets);
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
            await processTimesheetsFromResponse(timesheets);
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
