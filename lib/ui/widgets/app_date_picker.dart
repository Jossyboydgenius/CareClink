import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';

class AppDatePicker extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const AppDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.regular14,
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () {
            DatePicker.showDatePicker(
              context,
              showTitleActions: true,
              minTime: DateTime(2024, 1, 1),
              maxTime: DateTime(2025, 12, 31),
              onConfirm: onDateSelected,
              currentTime: selectedDate,
              locale: LocaleType.en,
              theme: DatePickerTheme(
                backgroundColor: AppColors.white,
                itemStyle: AppTextStyle.regular16,
                doneStyle: AppTextStyle.medium16.copyWith(
                  color: AppColors.primary,
                ),
                cancelStyle: AppTextStyle.medium16.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            );
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
                  _formatDate(selectedDate),
                  style: AppTextStyle.regular14,
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.grey300,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 