import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_icons.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;
  final bool showMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.showMarkAsRead = true,
  });

  String _getTimeAgo() {
    final difference = DateTime.now().difference(notification.timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

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
                notification.type,
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.grey300,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: 16.w,
                color: AppColors.grey300,
              ),
              AppSpacing.h4(),
              Text(
                _getTimeAgo(),
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
          AppSpacing.v12(),
          Text(
            notification.title,
            style: AppTextStyle.semibold16,
          ),
          AppSpacing.v8(),
          Text(
            notification.message,
            style: AppTextStyle.regular14.copyWith(
              color: AppColors.grey300,
              height: 1.5,
            ),
          ),
          if (showMarkAsRead && !notification.isRead) ...[
            AppSpacing.v12(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onMarkAsRead,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcons(
                      icon: AppIconData.check,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    AppSpacing.h4(),
                    Text(
                      'Mark as Read',
                      style: AppTextStyle.medium14.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 