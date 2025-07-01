import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pending_button/pending_button.dart';
import 'package:intl/intl.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../data/utils/timesheet_helper.dart';

enum DurationStatus {
  none,
  clockIn,
  clockOut,
}

class TimesheetCard extends StatefulWidget {
  final String staffName;
  final String clientName;
  final String clockIn;
  final String? clockOut;
  final String? rawClockOut; // Add raw clock out for proper validation
  final String? duration;
  final String status;
  final VoidCallback? onClockOut;
  final VoidCallback? onExpandDetails;
  final bool isClockingOut;

  const TimesheetCard({
    super.key,
    required this.staffName,
    required this.clientName,
    required this.clockIn,
    this.clockOut,
    this.rawClockOut,
    this.duration,
    required this.status,
    this.onClockOut,
    this.onExpandDetails,
    this.isClockingOut = false,
  });

  @override
  State<TimesheetCard> createState() => _TimesheetCardState();
}

class _TimesheetCardState extends State<TimesheetCard> {
  bool _isExpanded = false;

  // ignore: unused_element
  DurationStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'clockin':
        return DurationStatus.clockIn;
      case 'clockout':
        return DurationStatus.clockOut;
      default:
        return DurationStatus.none;
    }
  }

  // Format a datetime string to show time with AM/PM
  String _formatTimeWithAMPM(String dateTimeStr) {
    try {
      // Try to parse the date string
      final DateTime parsedDate = _parseDateTime(dateTimeStr);
      return DateFormat('h:mm a').format(parsedDate);
    } catch (e) {
      // If parsing fails, return the original string
      return dateTimeStr;
    }
  }

  // Helper method to parse datetime strings in various formats
  DateTime _parseDateTime(String dateTimeStr) {
    // Try standard ISO format first
    try {
      return DateTime.parse(dateTimeStr);
    } catch (_) {
      // Try other common formats
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd HH:mm',
        'yyyy/MM/dd HH:mm:ss',
        'yyyy/MM/dd HH:mm',
        'MM/dd/yyyy HH:mm',
        'dd/MM/yyyy HH:mm',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateTimeStr);
        } catch (_) {
          // Continue to next format
        }
      }

      // If all parsing attempts fail, use current date as fallback
      // but preserve the time if it's in a recognizable format
      if (dateTimeStr.contains(':')) {
        try {
          final timeParts = dateTimeStr.split(':');
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day, hour, minute);
        } catch (_) {
          // If time parsing fails, return current datetime
          return DateTime.now();
        }
      }

      // Last resort fallback
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Status is now determined using the helper class
    // Duration detection is not needed since we're not showing duration

    final clockInFormatted = _formatTimeWithAMPM(widget.clockIn);
    // Only format clockOut if it exists and isn't empty
    final clockOutFormatted =
        widget.clockOut != null && widget.clockOut!.isNotEmpty
            ? _formatTimeWithAMPM(widget.clockOut!)
            : null;

    // Debug info using the helper class
    TimesheetHelper.logTimesheetData('TimesheetCard', {
      'id': 'widget-${widget.clientName}',
      'status': widget.status,
      'clockIn': widget.clockIn,
      'clockOut': widget.clockOut,
    });

    // Log additional context data
    debugPrint(
        'TimesheetCard context: hasOnClockOut=${widget.onClockOut != null}, '
        'isClockingOut=${widget.isClockingOut}');

    // Determine if we should show the clock out button using our helper
    // Use rawClockOut for proper validation, fallback to clockOut if not available
    final clockOutForValidation = widget.rawClockOut ?? widget.clockOut;
    final bool shouldShowClockOutButton = widget.onClockOut != null &&
        TimesheetHelper.canClockOut(
            status: widget.status,
            clockOut: clockOutForValidation,
            isLoading: false // Widget has its own isClockingOut property
            );

    // Add more detailed debug output to diagnose issues
    debugPrint('TimesheetCard button logic: client=${widget.clientName}, '
        'status=${widget.status}, clockOut=${widget.clockOut}, '
        'rawClockOut=${widget.rawClockOut}, clockOutForValidation=$clockOutForValidation, '
        'hasOnClockOut=${widget.onClockOut != null}, '
        'isClockingOut=${widget.isClockingOut}, '
        'shouldShowClockOutButton=$shouldShowClockOutButton');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Staff name and clock out button/duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.clientName,
                        style: AppTextStyle.semibold16,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Only show the clock out button if conditions are met
                    if (shouldShowClockOutButton || widget.isClockingOut)
                      Container(
                        height: 32.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: widget.isClockingOut
                            ? Container(
                                width: 110.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  color: AppColors.grey200,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 14.w,
                                    height: 14.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              )
                            : PendingButton(
                                width: 110.w,
                                height: 32.h,
                                backgroundColor: AppColors.red,
                                foregroundColor: AppColors.white,
                                borderRadius: 8.r,
                                asynFunction: () async {
                                  if (widget.onClockOut != null) {
                                    widget.onClockOut!();
                                  }
                                  // Return a completed future for the button to work
                                  return Future.value();
                                },
                                child: Text(
                                  'Clock Out',
                                  style: AppTextStyle.regular14.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                      )
                    // Comment out duration as requested
                    /* else if (showDuration)
                      Row(
                        children: [
                          Text(
                            'Duration: ',
                            style: AppTextStyle.regular12.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            widget.duration ?? '0min',
                            style: AppTextStyle.semibold12,
                          ),
                        ],
                      ), */
                  ],
                ),
                AppSpacing.v12(),
                // Clock in/out times
                Row(
                  children: [
                    Text(
                      'Clock In: ',
                      style: AppTextStyle.regular12.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      clockInFormatted,
                      style: AppTextStyle.semibold12,
                    ),
                    if (clockOutFormatted != null) ...[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          height: 1,
                          color: AppColors.grey200,
                        ),
                      ),
                      Text(
                        'Clock Out: ',
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        clockOutFormatted,
                        style: AppTextStyle.semibold12,
                      ),
                    ],
                  ],
                ),
                AppSpacing.v12(),
                // Appointment Details dropdown
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    widget.onExpandDetails?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Appointment Details',
                              style: AppTextStyle.semibold12.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.grey,
                              size: 20.w,
                            ),
                          ],
                        ),
                        if (_isExpanded) ...[
                          AppSpacing.v12(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Appointment ID:',
                                style: AppTextStyle.regular12.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                widget.clientName,
                                style: AppTextStyle.medium12,
                              ),
                            ],
                          ),
                          AppSpacing.v12(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Date:',
                                    style: AppTextStyle.regular12.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(widget.clockIn),
                                    style: AppTextStyle.medium12,
                                  ),
                                ],
                              ),
                              AppSpacing.v8(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Time:',
                                    style: AppTextStyle.regular12.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    _formatTimeRange(
                                        widget.clockIn, widget.clockOut),
                                    style: AppTextStyle.medium12,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format date for the appointment details section
  String _formatDate(String dateTimeStr) {
    try {
      final DateTime parsedDate = _parseDateTime(dateTimeStr);
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      // Fallback to a default date if parsing fails
      return DateFormat('yyyy/MM/dd').format(DateTime.now());
    }
  }

  // Helper method to format time range for the appointment details section
  String _formatTimeRange(String startTimeStr, String? endTimeStr) {
    try {
      final DateTime startTime = _parseDateTime(startTimeStr);
      final String formattedStartTime = DateFormat('h:mm a').format(startTime);

      if (endTimeStr != null && endTimeStr.isNotEmpty) {
        try {
          final DateTime endTime = _parseDateTime(endTimeStr);
          final String formattedEndTime = DateFormat('h:mm a').format(endTime);
          return '$formattedStartTime - $formattedEndTime';
        } catch (e) {
          return formattedStartTime;
        }
      }

      return formattedStartTime;
    } catch (e) {
      // Fallback to a default time range if parsing fails
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));
      return '${DateFormat('h:mm a').format(now)} - ${DateFormat('h:mm a').format(later)}';
    }
  }
}
