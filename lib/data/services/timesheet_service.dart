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
        '/interpreter/get-timesheets',
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

  Future<ApiResponse> clockOut(String timesheetId) async {
    try {
      final response = await _api.putData(
        '/interpreter/check-out/$timesheetId',
        <String, dynamic>{},
      );

      if (response.isSuccessful) {
        // Use a microtask to allow UI to update before fetching timesheets
        Future.microtask(() async {
          // Fetch updated timesheets from backend
          final timesheetsResponse = await getTimesheets();
          if (timesheetsResponse.isSuccessful &&
              timesheetsResponse.data != null) {
            clearTimesheets();
            final timesheets = timesheetsResponse.data['timesheets'] as List;

            // Process timesheets in small batches to prevent UI freeze
            for (int i = 0; i < timesheets.length; i++) {
              final timesheet = timesheets[i];

              // Allow UI to update every few items
              if (i > 0 && i % 5 == 0) {
                await Future.delayed(Duration.zero);
              }

              // Process timesheet
              final clientData = timesheet['client'];
              String clientName = 'Unknown Client';
              if (clientData != null) {
                if (clientData is Map) {
                  clientName =
                      clientData['fullname']?.toString() ?? 'Unknown Client';
                } else if (clientData is String) {
                  clientName = clientData;
                }
              }

              addTimesheet({
                'id': timesheet['_id'],
                'clientName': clientName,
                'clockIn': timesheet['clockIn'],
                'clockOut': timesheet['clockOut'],
                'duration': timesheet['duration']?.toString() ?? '0',
                'status':
                    timesheet['clockOut'] == null ? 'clockin' : 'clockout',
              });
            }
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
}
