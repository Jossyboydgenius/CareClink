import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_icons.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/notification_card.dart';
import '../widgets/user_avatar.dart';
import '../../data/models/notification_model.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';
import '../../shared/app_images.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _notificationsEnabled = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
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
                  AppImages(
                    imagePath: AppImageData.careclinkLogo,
                    height: 60,
                    width: 160,
                  ),
                  const UserAvatar(),
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
                      onTap: () {
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentIndex == 0 ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Unread',
                          style: AppTextStyle.medium14.copyWith(
                            color: _currentIndex == 0 ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h16(),
                    InkWell(
                      onTap: () {
                        _tabController.animateTo(1);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentIndex == 1 ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'All',
                          style: AppTextStyle.medium14.copyWith(
                            color: _currentIndex == 1 ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_currentIndex == 0 && unreadNotifications.isNotEmpty)
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
                              size: 14,
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
                    // Unread tab
                    unreadNotifications.isNotEmpty
                        ? SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
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
                                }).toList(),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              'No unread notifications',
                              style: AppTextStyle.regular14.copyWith(
                                color: AppColors.grey300,
                              ),
                            ),
                          ),
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
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32.h),
                                    child: Text(
                                      'No notifications',
                                      style: AppTextStyle.regular14.copyWith(
                                        color: AppColors.grey300,
                                      ),
                                    ),
                                  ),
                                ],
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