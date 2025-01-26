import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';

class TimesheetCard extends StatefulWidget {
  final String visitId;
  final String clockIn;
  final String? clockOut;
  final String? duration;
  final bool showClockOut;
  final VoidCallback? onClockOut;
  final VoidCallback? onExpandDetails;

  const TimesheetCard({
    super.key,
    required this.visitId,
    required this.clockIn,
    this.clockOut,
    this.duration,
    this.showClockOut = false,
    this.onClockOut,
    this.onExpandDetails,
  });

  @override
  State<TimesheetCard> createState() => _TimesheetCardState();
}

class _TimesheetCardState extends State<TimesheetCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                // Visit ID and Clock Out button/Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '# ${widget.visitId}',
                      style: AppTextStyle.semibold16,
                    ),
                    if (widget.showClockOut)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: TextButton(
                          onPressed: widget.onClockOut,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            minimumSize: Size(0, 24.h),
                            textStyle: AppTextStyle.medium12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text('Clock Out'),
                        ),
                      )
                    else if (widget.duration != null)
                      Row(
                        children: [
                          Text(
                            'Duration: ',
                            style: AppTextStyle.regular12.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            widget.duration!,
                            style: AppTextStyle.semibold12,
                          ),
                        ],
                      ),
                  ],
                ),
                AppSpacing.v12(),
                // Clock in time
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
                    if (widget.clockOut != null) ...[
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
                    child: Row(
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expanded details section
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        widget.visitId,
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
              ),
            ),
        ],
      ),
    );
  }
} 
