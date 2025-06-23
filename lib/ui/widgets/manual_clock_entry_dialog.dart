import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../data/services/navigator_service.dart';
import '../../data/models/appointment_model.dart';
import 'app_button.dart';
import 'app_date_picker.dart';
import 'app_time_picker.dart';

class ManualClockEntryDialog extends StatefulWidget {
  final String appointmentId;
  final String clientName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final Function(
          DateTime date, TimeOfDay clockIn, TimeOfDay clockOut, String reason)
      onSave;

  const ManualClockEntryDialog({
    super.key,
    required this.appointmentId,
    required this.clientName,
    required this.dateTime,
    required this.status,
    required this.onSave,
  });

  @override
  State<ManualClockEntryDialog> createState() => _ManualClockEntryDialogState();
}

class _ManualClockEntryDialogState extends State<ManualClockEntryDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _clockInTime;
  late TimeOfDay _clockOutTime;
  String? _selectedReason;
  String? _reasonError;

  final List<String> _reasons = [
    'Delayed',
    'Traffic',
    'Weather',
    'Emergency',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.dateTime;
    _clockInTime = TimeOfDay.fromDateTime(widget.dateTime);
    _clockOutTime = TimeOfDay(
      hour: _clockInTime.hour + 1,
      minute: _clockInTime.minute,
    );
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case AppointmentStatus.scheduled:
        return AppColors.orange;
      case AppointmentStatus.completed:
        return AppColors.green;
      case AppointmentStatus.pending:
        return AppColors.orange;
      case AppointmentStatus.reschedule:
        return AppColors.red;
      default:
        return AppColors.textPrimary;
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.reschedule:
        return 'Reschedule';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 0.98.sw,
        padding: EdgeInsets.all(14.w),
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
                  onPressed: () => NavigationService.pop(),
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
            // Appointment ID row
            Row(
              children: [
                Text(
                  'Appointment ID: ',
                  style: AppTextStyle.regular14,
                ),
                Expanded(
                  child: Text(
                    widget.clientName,
                    style: AppTextStyle.semibold14,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Status row
            AppSpacing.v4(),
            Row(
              children: [
                Text(
                  'Status: ',
                  style: AppTextStyle.regular14,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: AppTextStyle.medium12.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.v12(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${_formatDate(widget.dateTime)}',
                  style: AppTextStyle.semibold14,
                ),
                AppSpacing.v4(),
                Text(
                  'Time: ${_formatTime(TimeOfDay.fromDateTime(widget.dateTime))}',
                  style: AppTextStyle.semibold14,
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
              selectedTime: _clockInTime,
              onTimeSelected: (time) => setState(() => _clockInTime = time),
            ),
            AppSpacing.v12(),
            AppTimePicker(
              label: 'Clock Out',
              selectedTime: _clockOutTime,
              onTimeSelected: (time) => setState(() => _clockOutTime = time),
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
                hintText: 'Select reason...',
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
                  _reasonError = null;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a reason';
                }
                return null;
              },
            ),
            if (_reasonError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _reasonError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            AppSpacing.v16(),
            AppButton(
              text: 'Save',
              onPressed: () {
                if (_selectedReason == null) {
                  setState(() {
                    _reasonError = 'Please select a reason';
                  });
                  return;
                }

                if (_validateTimes()) {
                  widget.onSave(
                    _selectedDate,
                    _clockInTime,
                    _clockOutTime,
                    _selectedReason!,
                  );
                }
              },
              isLoading: false,
              enabled: _selectedReason != null,
            ),
          ],
        ),
      ),
    );
  }

  bool _validateTimes() {
    return true;
  }
}
