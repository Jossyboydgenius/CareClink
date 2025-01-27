import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_icons.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/notification_card.dart';
import '../../data/models/notification_model.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleMarkAsRead(String id) {
    setState(() {
      NotificationService.markAsRead(id);
    });
  }

  void _handleMarkAllAsRead() {
    setState(() {
      NotificationService.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifications = NotificationService.getUnreadNotifications();
    final allNotifications = NotificationService.getAllNotifications();

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
                      color: const Color(0xFF48C79F),
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
                    inactiveThumbColor: AppColors.white,
                    inactiveTrackColor: AppColors.grey200,
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),
            if (_notificationsEnabled) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _tabController.index = 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _tabController.index == 0 ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'All',
                          style: AppTextStyle.medium14.copyWith(
                            color: _tabController.index == 0 ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h16(),
                    InkWell(
                      onTap: () => _tabController.index = 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _tabController.index == 1 ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Unread',
                          style: AppTextStyle.medium14.copyWith(
                            color: _tabController.index == 1 ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_tabController.index == 1 && unreadNotifications.isNotEmpty)
                      TextButton(
                        onPressed: _handleMarkAllAsRead,
                        style: TextButton.styleFrom(
                          textStyle: AppTextStyle.medium14.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        child: Row(
                          children: [
                            AppIcons(
                              icon: AppIconData.check,
                              size: 20,
                              color: AppColors.primary,
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
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          if (allNotifications.isNotEmpty)
                            ...allNotifications.map((notification) {
                              return Column(
                                children: [
                                  NotificationCard(
                                    notification: notification,
                                    showMarkAsRead: !notification.isRead,
                                    onMarkAsRead: () => _handleMarkAsRead(notification.id),
                                  ),
                                  if (notification != allNotifications.last)
                                    AppSpacing.v16(),
                                ],
                              );
                            }).toList()
                          else
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.h),
                                child: Text(
                                  'No notifications',
                                  style: AppTextStyle.regular14.copyWith(
                                    color: AppColors.grey300,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Unread tab
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          if (unreadNotifications.isNotEmpty)
                            ...unreadNotifications.map((notification) {
                              return Column(
                                children: [
                                  NotificationCard(
                                    notification: notification,
                                    onMarkAsRead: () => _handleMarkAsRead(notification.id),
                                  ),
                                  if (notification != unreadNotifications.last)
                                    AppSpacing.v16(),
                                ],
                              );
                            }).toList()
                          else
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.h),
                                child: Text(
                                  'No unread notifications',
                                  style: AppTextStyle.regular14.copyWith(
                                    color: AppColors.grey300,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 48.w,
                        color: AppColors.grey300,
                      ),
                      AppSpacing.v16(),
                      Text(
                        'Notifications are turned off',
                        style: AppTextStyle.regular14.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                      AppSpacing.v8(),
                      Text(
                        'Turn on notifications to stay updated',
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            NavigationService.pushNamed(AppRoutes.dashboardView);
          }
        },
      ),
    );
  }
} 