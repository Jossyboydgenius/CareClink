import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

  // Parse the combined dateTime string to extract date and time parts
  List<String> _parseDateTimeString() {
    // Expected format from API: YYYY-MM-DD HH:MM - HH:MM AM/PM
    final parts = dateTime.split(' ');
    if (parts.length >= 4) {
      // Extract date part (YYYY-MM-DD)
      final datePart = parts[0];

      try {
        // Parse the date to reformat it
        final parsedDate = DateFormat('yyyy-MM-dd').parse(datePart);
        final formattedDate = DateFormat('yyyy/MM/dd').format(parsedDate);

        // Combine the time parts
        final timePart = parts.sublist(1).join(' ');

        return ['Date: $formattedDate', 'Time: $timePart'];
      } catch (e) {
        return ['Date: $datePart', 'Time: ${parts.sublist(1).join(' ')}'];
      }
    }

    // Fallback if the format is unexpected
    return ['Date & Time:', dateTime];
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeParts = _parseDateTimeString();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointment ID row
            Row(
              children: [
                Text(
                  'Appointment ID: ',
                  style: AppTextStyle.regular14.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    clientName,
                    style: AppTextStyle.semibold14.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            // Status row
            if (status != AppointmentStatus.none) ...[
              AppSpacing.v4(),
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: AppTextStyle.regular14.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
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
            ],
            AppSpacing.v8(),
            // Display date and time separately
            Text(
              dateTimeParts[0],
              style: AppTextStyle.regular14.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            AppSpacing.v4(),
            Text(
              dateTimeParts[1],
              style: AppTextStyle.semibold14.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
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
      case AppointmentStatus.inProgress:
        return AppColors.purple;
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
      case AppointmentStatus.inProgress:
        return 'In Progress';
      default:
        return '';
    }
  }
}
