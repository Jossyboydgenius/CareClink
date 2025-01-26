import 'package:flutter/material.dart';
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '# ${widget.visitId}',
                      style: AppTextStyle.semibold14,
                    ),
                    if (widget.clockOut == null)
                      OutlinedButton(
                        onPressed: widget.onClockOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Clock Out',
                          style: AppTextStyle.medium12,
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
                            style: AppTextStyle.regular12,
                          ),
                          Text(
                            widget.clockIn,
                            style: AppTextStyle.semibold12,
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
                              style: AppTextStyle.regular12,
                            ),
                            Text(
                              widget.clockOut!,
                              style: AppTextStyle.semibold12,
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
                        style: AppTextStyle.medium12,
                      ),
                      Text(
                        widget.duration!,
                        style: AppTextStyle.semibold12,
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
              padding: const EdgeInsets.all(16),
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
                    style: AppTextStyle.medium12.copyWith(color: AppColors.grey300),
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
              padding: const EdgeInsets.all(16),
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
                              style: AppTextStyle.regular12,
                            ),
                            AppSpacing.v4(),
                            Text(
                              '1001',
                              style: AppTextStyle.semibold12,
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
                              style: AppTextStyle.regular12,
                            ),
                            AppSpacing.v4(),
                            Text(
                              '2025-01-15\n10:00 - 11:00 AM',
                              style: AppTextStyle.semibold12,
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
