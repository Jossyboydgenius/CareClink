import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';

enum AppointmentStatus {
  none,
  pending,
  reschedule,
}

class AppointmentCard extends StatelessWidget {
  final String appointmentId;
  final String dateTime;
  final AppointmentStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointmentId,
    required this.dateTime,
    this.status = AppointmentStatus.none,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Appointment ID: ',
                      style: AppTextStyle.regular14.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      appointmentId,
                      style: AppTextStyle.semibold14.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (status != AppointmentStatus.none)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: AppTextStyle.medium12.copyWith(
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.v8(),
            Row(
              children: [
                Text(
                  'Date & Time: ',
                  style: AppTextStyle.regular14.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  dateTime,
                  style: AppTextStyle.semibold14.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.orange;
      case AppointmentStatus.reschedule:
        return AppColors.red;
      default:
        return AppColors.textPrimary;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.reschedule:
        return 'Reschedule';
      default:
        return '';
    }
  }
}
