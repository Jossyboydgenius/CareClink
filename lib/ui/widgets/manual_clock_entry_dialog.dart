import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import 'app_button.dart';

class ManualClockEntryDialog extends StatefulWidget {
  final String appointmentId;
  final String dateTime;

  const ManualClockEntryDialog({
    super.key,
    required this.appointmentId,
    required this.dateTime,
  });

  @override
  State<ManualClockEntryDialog> createState() => _ManualClockEntryDialogState();
}

class _ManualClockEntryDialogState extends State<ManualClockEntryDialog> {
  bool _isLoading = false;
  String? _selectedReason;
  final List<String> _reasons = [
    'Appointment Completed',
    'Reschedule',
    'No Show',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 0.95.sw,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manual Clock Entry',
                  style: AppTextStyle.semibold20,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.grey300,
                    size: 24.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            AppSpacing.v16(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment ID:',
                  style: AppTextStyle.regular14,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Pending',
                        style: AppTextStyle.medium12.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSpacing.h8(),
                    Text(
                      widget.appointmentId,
                      style: AppTextStyle.semibold14,
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.v12(),
            Row(
              children: [
                Text(
                  'Date & Time:',
                  style: AppTextStyle.regular14,
                ),
                AppSpacing.h8(),
                Text(
                  widget.dateTime,
                  style: AppTextStyle.semibold14,
                ),
              ],
            ),
            AppSpacing.v16(),
            Text(
              'Clock In',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            InkWell(
              onTap: () {
                // Show time picker
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00 : 00',
                      style: AppTextStyle.regular14,
                    ),
                    Icon(
                      Icons.access_time,
                      color: AppColors.grey300,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.v12(),
            Text(
              'Clock Out',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            InkWell(
              onTap: () {
                // Show time picker
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00 : 00',
                      style: AppTextStyle.regular14,
                    ),
                    Icon(
                      Icons.access_time,
                      color: AppColors.grey300,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.v12(),
            Text(
              'Reason',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              dropdownColor: AppColors.white,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                hintText: 'Select item...',
                hintStyle: AppTextStyle.regular14.copyWith(
                  color: AppColors.grey300,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.grey300,
                size: 24.w,
              ),
              items: _reasons.map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(
                    reason,
                    style: AppTextStyle.regular14,
                  ),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedReason = value;
                });
              },
            ),
            AppSpacing.v16(),
            AppButton(
              text: 'Save',
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });

                // Simulate save delay
                await Future.delayed(const Duration(seconds: 2));

                setState(() {
                  _isLoading = false;
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully saved manual clock entry',
                        style: AppTextStyle.regular14.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      backgroundColor: AppColors.green200,
                    ),
                  );
                }
              },
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
} 