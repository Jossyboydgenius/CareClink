import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../widgets/bottom_nav_bar.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  bool _showUnread = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Profile
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logo',
                        style: AppTextStyle.semibold24.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' Company',
                        style: AppTextStyle.regular24.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Color(0xFF48C79F),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'JD',
                        style: AppTextStyle.semibold14.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Notification Title and Toggle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notification',
                    style: AppTextStyle.semibold24,
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),
            // Filter Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  _buildFilterTab('All', !_showUnread),
                  AppSpacing.h16(),
                  _buildFilterTab('Unread', _showUnread),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primary,
                          size: 20.w,
                        ),
                        AppSpacing.h4(),
                        Text(
                          'Mark All as Read',
                          style: AppTextStyle.medium14.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),
            // Notification List
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  _buildNotificationCard(
                    title: "Reminder: Don't Forget to Clock In!",
                    message: 'Hi,\nThis is a friendly reminder to clock in for your shift scheduled at [Start Time]. Please ensure you record your start time promptly.\nIf you\'ve already clocked in, kindly ignore this message',
                    type: 'Reminder to Clock In/Out',
                    time: '1 min ago',
                  ),
                  AppSpacing.v16(),
                  _buildNotificationCard(
                    title: 'Complete Your Clock-Out',
                    message: 'Hi,\nIt seems you haven\'t clocked out for your shift starting at [Start Time]. Please remember to clock out once your shift is complete.\nIf this was an oversight, you can log your clock-out time or submit a manual entry with a reason.',
                    type: 'Reminder to Clock In/Out',
                    time: '2 min ago',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildFilterTab(String text, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _showUnread = text == 'Unread';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyle.medium14.copyWith(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String type,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
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
              onPressed: () {},
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