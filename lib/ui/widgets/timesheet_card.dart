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
  final VoidCallback onClockOut;
  final VoidCallback onExpandDetails;

  const TimesheetCard({
    super.key,
    required this.visitId,
    required this.clockIn,
    this.clockOut,
    this.duration,
    required this.onClockOut,
    required this.onExpandDetails,
  });

  @override
  State<TimesheetCard> createState() => _TimesheetCardState();
}

class _TimesheetCardState extends State<TimesheetCard> {
  bool _isExpanded = false;

  TextStyle get _visitIdStyle => AppTextStyle.semibold14;
  TextStyle get _labelStyle => AppTextStyle.regular12;
  TextStyle get _valueStyle => AppTextStyle.semibold12;
  TextStyle get _buttonStyle => AppTextStyle.medium12;
  TextStyle get _detailsStyle => AppTextStyle.medium12;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '# ${widget.visitId}',
                      style: _visitIdStyle,
                    ),
                    if (widget.clockOut == null)
                      OutlinedButton(
                        onPressed: widget.onClockOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Clock Out',
                          style: _buttonStyle.copyWith(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
                AppSpacing.v8(),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            'Clock In: ',
                            style: _labelStyle,
                          ),
                          Text(
                            widget.clockIn,
                            style: _valueStyle,
                          ),
                        ],
                      ),
                    ),
                    if (widget.clockOut != null) ...[
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Clock Out: ',
                              style: _labelStyle,
                            ),
                            Text(
                              widget.clockOut!,
                              style: _valueStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.duration != null) ...[
                  AppSpacing.v4(),
                  Row(
                    children: [
                      Text(
                        'Duration: ',
                        style: _labelStyle,
                      ),
                      Text(
                        widget.duration!,
                        style: _valueStyle,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onExpandDetails();
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointment Details',
                    style: _detailsStyle.copyWith(color: AppColors.grey300),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.grey300,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appointment ID:',
                              style: _labelStyle,
                            ),
                            AppSpacing.v4(),
                            Text(
                              '1001',
                              style: _valueStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date and Time:',
                              style: _labelStyle,
                            ),
                            AppSpacing.v4(),
                            Text(
                              '2025-01-15\n10:00 - 11:00 AM',
                              style: _valueStyle,
                            ),
                          ],
                        ),
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
