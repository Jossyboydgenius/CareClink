import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_snackbar.dart';
import '../../data/services/navigator_service.dart';
import 'app_button.dart';
import 'app_date_picker.dart';
import 'app_time_picker.dart';

class ManualClockEntryDialog extends StatefulWidget {
  final String appointmentId;
  final String dateTime;
  final Function(DateTime date, TimeOfDay clockIn, TimeOfDay clockOut) onSave;

  const ManualClockEntryDialog({
    super.key,
    required this.appointmentId,
    required this.dateTime,
    required this.onSave,
  });

  @override
  State<ManualClockEntryDialog> createState() => _ManualClockEntryDialogState();
}

class _ManualClockEntryDialogState extends State<ManualClockEntryDialog> {
  bool _isLoading = false;
  String? _selectedReason;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedClockIn = TimeOfDay.now();
  TimeOfDay _selectedClockOut = TimeOfDay.now();
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
        width: 0.98.sw,
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
                  onPressed: () => NavigationService.goBack(),
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
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      Flexible(
                        child: Text(
                          widget.appointmentId,
                          style: AppTextStyle.semibold14,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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
                Expanded(
                  child: Text(
                    widget.dateTime,
                    style: AppTextStyle.semibold14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppSpacing.v16(),
            AppDatePicker(
              label: 'Date',
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            AppSpacing.v12(),
            AppTimePicker(
              label: 'Clock In',
              selectedTime: _selectedClockIn,
              onTimeSelected: (time) => setState(() => _selectedClockIn = time),
            ),
            AppSpacing.v12(),
            AppTimePicker(
              label: 'Clock Out',
              selectedTime: _selectedClockOut,
              onTimeSelected: (time) => setState(() => _selectedClockOut = time),
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
              onPressed: () {
                setState(() => _isLoading = true);
                Future<void>.delayed(const Duration(seconds: 2)).then((_) {
                  if (!mounted) return;
                  setState(() => _isLoading = false);
                  widget.onSave(_selectedDate, _selectedClockIn, _selectedClockOut);
                  NavigationService.goBack();
                  AppSnackbar.showSnackBar(
                    message: 'Successfully saved manual clock entry',
                    color: AppColors.green200,
                  );
                });
              },
              isLoading: _isLoading,
              enabled: _selectedReason != null,
            ),
          ],
        ),
      ),
    );
  }
} 