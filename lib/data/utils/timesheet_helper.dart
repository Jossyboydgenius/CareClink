import 'package:flutter/foundation.dart';

/// Helper class for timesheet-related utility functions
class TimesheetHelper {
  /// Determines the correct status for a timesheet based on its data
  /// This ensures consistent status determination across the app
  static String determineTimesheetStatus({
    required dynamic rawStatus,
    required dynamic clockOut,
    String defaultStatus = 'clockin',
  }) {
    // Debug information
    debugPrint(
        'TimesheetHelper.determineTimesheetStatus: rawStatus=$rawStatus, clockOut=$clockOut');

    // First priority: If there's a valid clock out time, status must be 'clockout'
    bool hasValidClockOut = false;
    if (clockOut != null) {
      String clockOutStr = clockOut.toString().trim();
      hasValidClockOut = clockOutStr.isNotEmpty &&
          clockOutStr != 'null' &&
          clockOutStr != '0' &&
          clockOutStr != '0:00' &&
          !clockOutStr.toLowerCase().contains('null');

      // Debug the clockOut check
      debugPrint(
          '  → clockOut check: "$clockOutStr", isValid: $hasValidClockOut');
    } else {
      debugPrint('  → clockOut is null');
    }

    if (hasValidClockOut) {
      debugPrint('  → Setting status to "clockout" based on clockOut value');
      return 'clockout';
    }

    // Second priority: If there's a valid status from API, use it
    if (rawStatus != null) {
      String status = rawStatus.toString().toLowerCase().trim();

      // Convert 'completed' status to 'clockout' for consistency
      if (status == 'completed') {
        debugPrint('  → Converting "completed" status to "clockout"');
        return 'clockout';
      }

      // Handle other status values
      if (status == 'in progress' || status == 'inprogress') {
        debugPrint('  → Converting "in progress" status to "clockin"');
        return 'clockin';
      }

      debugPrint('  → Using rawStatus: "$status"');
      return status;
    }

    // Default to clockin if no other determination can be made
    debugPrint('  → Using default status: "$defaultStatus"');
    return defaultStatus;
  }

  /// Check if a timesheet can be clocked out
  static bool canClockOut({
    required String status,
    required dynamic clockOut,
    bool isLoading = false,
  }) {
    // Cannot clock out if already loading
    if (isLoading) return false;

    // Debug log to help diagnose issues
    debugPrint(
        'TimesheetHelper.canClockOut check: status=$status, clockOut=$clockOut');

    // Convert status to lowercase for consistent comparison
    final normalizedStatus = status.toLowerCase();

    // Cannot clock out if already clocked out (status is 'clockout' or 'completed')
    if (normalizedStatus == 'clockout' || normalizedStatus == 'completed') {
      debugPrint('  → Cannot clock out: status is already $normalizedStatus');
      return false;
    }

    // Cannot clock out if already has a valid clockOut time
    if (clockOut != null) {
      // Check more thoroughly for valid clockOut values
      String clockOutStr = clockOut.toString().trim();
      bool hasValidClockOut = clockOutStr.isNotEmpty &&
          clockOutStr != 'null' &&
          clockOutStr != '0' &&
          clockOutStr != '0:00';

      if (hasValidClockOut) {
        debugPrint(
            '  → Cannot clock out: already has clockOut time: $clockOutStr');
        return false;
      }
    }

    // All conditions met, can clock out
    debugPrint('  → Can clock out: all conditions met');
    return true;
  }

  /// Logs timesheet data for debugging
  static void logTimesheetData(String prefix, Map<String, dynamic> timesheet) {
    debugPrint('$prefix: id=${timesheet['id']}, '
        'status=${timesheet['status']}, '
        'clockIn=${timesheet['clockIn']}, '
        'clockOut=${timesheet['clockOut']}');
  }
}
