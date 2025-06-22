import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../data/services/timesheet_service.dart';

class ClockOutReasonDialog extends StatefulWidget {
  const ClockOutReasonDialog({
    super.key,
  });

  @override
  State<ClockOutReasonDialog> createState() => _ClockOutReasonDialogState();
}

class _ClockOutReasonDialogState extends State<ClockOutReasonDialog> {
  final _otherReasonController = TextEditingController();
  String? _selectedReason;
  bool _isOtherSelected = false;
  final _formKey = GlobalKey<FormState>();
  final TimesheetService _timesheetService = TimesheetService();

  @override
  void initState() {
    super.initState();
    // Default reason is not selected, user must choose
    _selectedReason = null;
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clock Out Reason',
                style: AppTextStyle.semibold18.copyWith(
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.v16(),
              Text(
                'Please select a reason for clocking out:',
                style: AppTextStyle.regular14,
              ),
              AppSpacing.v16(),
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
                items:
                    _timesheetService.getClockOutReasons().map((String reason) {
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
                    _isOtherSelected = value == 'Other';
                    if (!_isOtherSelected) {
                      _otherReasonController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              if (_isOtherSelected) ...[
                AppSpacing.v16(),
                TextFormField(
                  controller: _otherReasonController,
                  decoration: InputDecoration(
                    hintText: 'Please specify reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (_isOtherSelected && (value == null || value.isEmpty)) {
                      return 'Please specify a reason';
                    }
                    return null;
                  },
                ),
              ],
              AppSpacing.v16(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.grey300,
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.medium14,
                    ),
                  ),
                  AppSpacing.h16(),
                  ElevatedButton(
                    onPressed: _submitReason,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: AppTextStyle.medium14.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReason() {
    if (_formKey.currentState!.validate()) {
      final reason = _isOtherSelected
          ? _otherReasonController.text.trim()
          : _selectedReason!;
      Navigator.of(context).pop(reason);
    }
  }
}

// Helper function to show the clock out reason dialog
Future<String?> showClockOutReasonDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const ClockOutReasonDialog();
    },
  );
}
