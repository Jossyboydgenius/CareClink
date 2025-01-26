import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/notification_card.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  bool _showUnread = false;
  bool _notificationsEnabled = true;

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
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    activeColor: AppColors.white,
                    activeTrackColor: AppColors.primary,
                    inactiveThumbColor: AppColors.grey300,
                    inactiveTrackColor: AppColors.grey200,
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
                    style: TextButton.styleFrom(
                      textStyle: AppTextStyle.medium14.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
                            decoration: TextDecoration.underline,
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
              child: _showUnread
                  ? Center(
                      child: Text(
                        'No unread notifications',
                        style: AppTextStyle.regular14.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        NotificationCard(
                          title: "Reminder: Don't Forget to Clock In!",
                          message: 'Hi,\nThis is a friendly reminder to clock in for your shift scheduled at [Start Time]. Please ensure you record your start time promptly.\nIf you\'ve already clocked in, kindly ignore this message',
                          type: 'Reminder to Clock In/Out',
                          time: '1 min ago',
                          onMarkAsRead: () {},
                        ),
                        AppSpacing.v16(),
                        NotificationCard(
                          title: 'Complete Your Clock-Out',
                          message: 'Hi,\nIt seems you haven\'t clocked out for your shift starting at [Start Time]. Please remember to clock out once your shift is complete.\nIf this was an oversight, you can log your clock-out time or submit a manual entry with a reason.',
                          type: 'Reminder to Clock In/Out',
                          time: '2 min ago',
                          onMarkAsRead: () {},
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
} 