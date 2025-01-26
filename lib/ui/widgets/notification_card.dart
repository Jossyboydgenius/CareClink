import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String type;
  final String time;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.grey300,
                size: 20.w,
              ),
              AppSpacing.h8(),
              Text(
                type,
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.grey300,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
          AppSpacing.v12(),
          Text(
            title,
            style: AppTextStyle.semibold16,
          ),
          AppSpacing.v8(),
          Text(
            message,
            style: AppTextStyle.regular14.copyWith(
              color: AppColors.grey300,
              height: 1.5,
            ),
          ),
          AppSpacing.v12(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onMarkAsRead,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 20.w,
                  ),
                  AppSpacing.h4(),
                  Text(
                    'Mark as Read',
                    style: AppTextStyle.medium14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 