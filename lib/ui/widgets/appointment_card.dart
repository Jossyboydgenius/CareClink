import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../data/models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final String clientName;
  final String dateTime;
  final AppointmentStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.clientName,
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
                Text(
                  'Appointment ID: ',
                  style: AppTextStyle.regular14.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status != AppointmentStatus.none)
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
                      AppSpacing.h8(),
                      Flexible(
                        child: Text(
                          clientName,
                          style: AppTextStyle.semibold14.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
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
                Expanded(
                  child: Text(
                    dateTime,
                    style: AppTextStyle.semibold14.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
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
    switch (status) {
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
}
