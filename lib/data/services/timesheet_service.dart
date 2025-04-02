import '../models/timesheet_model.dart';

class TimesheetService {
  static final TimesheetService _instance = TimesheetService._internal();
  factory TimesheetService() => _instance;
  TimesheetService._internal();

  final List<TimesheetModel> _recentTimesheets = [];

  List<Map<String, dynamic>> get recentTimesheets => 
    _recentTimesheets.map((timesheet) => timesheet.toMap()).toList();

  Map<String, dynamic>? getTimesheet(String id) {
    try {
      final timesheet = _recentTimesheets.firstWhere(
        (timesheet) => timesheet.id == id,
      );
      return timesheet.toMap();
    } catch (e) {
      return null;
    }
  }

  void addTimesheet(Map<String, dynamic> timesheetData) {
    // Check if timesheet already exists
    final existingIndex = _recentTimesheets.indexWhere(
      (timesheet) => timesheet.id == timesheetData['id']
    );
    
    if (existingIndex == -1) {
      // Only add if it doesn't exist
      final timesheet = TimesheetModel.fromMap(timesheetData);
      _recentTimesheets.add(timesheet);
    }
  }

  void updateTimesheet(String id, Map<String, dynamic> timesheetData) {
    final index = _recentTimesheets.indexWhere((timesheet) => timesheet.id == id);
    if (index != -1) {
      _recentTimesheets[index] = TimesheetModel.fromMap(timesheetData);
    }
  }

  void clearTimesheets() {
    _recentTimesheets.clear();
  }
} 