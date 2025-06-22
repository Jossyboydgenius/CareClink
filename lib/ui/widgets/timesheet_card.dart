import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pending_button/pending_button.dart';
import 'package:intl/intl.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';

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

  // Format a datetime string to show date and time separately
  List<String> _formatDateTime(String dateTimeStr) {
    try {
      // Try to parse the date string
      final DateTime parsedDate = DateTime.parse(dateTimeStr);
      final String formattedDate = DateFormat('yyyy/MM/dd').format(parsedDate);
      final String formattedTime = DateFormat('h:mm a').format(parsedDate);
      return ['Date: $formattedDate', 'Time: $formattedTime'];
    } catch (e) {
      // If parsing fails, return the original string
      return ['Date:', dateTimeStr];
    }
  }

  @override
  Widget build(BuildContext context) {
    _getStatusFromString(widget.status);
    // Commented out as requested
    // final bool showDuration = widget.duration != null &&
    //     widget.duration!.isNotEmpty &&
    //     widget.duration != '0min';

    final clockInFormatted = _formatDateTime(widget.clockIn);
    final clockOutFormatted =
        widget.clockOut != null && widget.clockOut!.isNotEmpty
            ? _formatDateTime(widget.clockOut!)
            : null;

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
                    if (widget.onClockOut != null || widget.isClockingOut)
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
                    /* Commented out as requested
                    else if (showDuration)
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
                      ),
                    */
                  ],
                ),
                AppSpacing.v12(),
                // Clock in details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clock In',
                      style: AppTextStyle.regular12.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    AppSpacing.v4(),
                    Text(
                      clockInFormatted[0],
                      style: AppTextStyle.semibold12,
                    ),
                    Text(
                      clockInFormatted[1],
                      style: AppTextStyle.semibold12,
                    ),
                  ],
                ),
                // Clock out details if available
                if (clockOutFormatted != null) ...[
                  AppSpacing.v8(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clock Out',
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      AppSpacing.v4(),
                      Text(
                        clockOutFormatted[0],
                        style: AppTextStyle.semibold12,
                      ),
                      Text(
                        clockOutFormatted[1],
                        style: AppTextStyle.semibold12,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
