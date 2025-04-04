import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _isExpanded = false;

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

  @override
  Widget build(BuildContext context) {
    final status = _getStatusFromString(widget.status);
    final bool showDuration = widget.duration != null && widget.duration!.isNotEmpty && widget.duration != '0min';

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
                          color: widget.isClockingOut ? AppColors.grey200 : AppColors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextButton(
                          onPressed: widget.isClockingOut ? null : widget.onClockOut,
                          style: TextButton.styleFrom(
                            foregroundColor: widget.isClockingOut ? AppColors.grey : AppColors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            textStyle: AppTextStyle.regular14.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            backgroundColor: widget.isClockingOut ? AppColors.grey200 : null,
                            disabledForegroundColor: AppColors.grey,
                          ),
                          child: Text(
                            'Clock Out',
                            style: TextStyle(
                              color: widget.isClockingOut ? AppColors.grey : AppColors.white,
                            ),
                          ),
                        ),
                      )
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
                      widget.clockIn,
                      style: AppTextStyle.semibold12,
                    ),
                    if (widget.clockOut != null && widget.clockOut!.isNotEmpty) ...[
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
                        widget.clockOut!,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date and Time:',
                                style: AppTextStyle.regular12.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                '2025-01-15\n10:00 - 11:00 AM',
                                style: AppTextStyle.medium12,
                                textAlign: TextAlign.end,
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
} 
