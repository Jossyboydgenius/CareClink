import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/app_icons.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_skeleton.dart';
import '../widgets/user_avatar.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';
import '../../shared/app_images.dart';
import '../../app/locator.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_model.dart';
import '../../app/navigation_state_manager.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _notificationsEnabled = true;
  final NotificationService _notificationService =
      locator<NotificationService>();
  final NavigationStateManager _stateManager =
      locator<NavigationStateManager>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes to load appropriate data
    _tabController.addListener(_handleTabChange);

    // Force refresh notifications when view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialLoad();
    });
  }

  void _handleInitialLoad() async {
    // Load data for the initial tab
    if (_tabController.index == 0) {
      await _handlePullToRefreshUnread();
    } else {
      await _handlePullToRefresh();
    }
  }

  void _handleTabChange() {
    // When tab changes, load appropriate data
    if (_tabController.index == 0) {
      _handlePullToRefreshUnread();
    } else {
      _handlePullToRefresh();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleMarkAsRead(String id) async {
    await _notificationService.markAsRead(id);
  }

  void _handleMarkAllAsRead() async {
    await _notificationService.markAllAsRead();
    // Refresh unread notifications after marking all as read
    await _handlePullToRefreshUnread();
  }

  // For All Notifications tab
  Future<void> _handlePullToRefresh() async {
    // Force refresh all notifications
    await _stateManager.forceRefreshNotifications();
  }

  // For Unread Notifications tab
  Future<void> _handlePullToRefreshUnread() async {
    // Force refresh unread notifications
    await _stateManager.forceRefreshUnreadNotifications();
  }

  Future<void> _handlePullToRefreshAll() async {
    // Show temporary loading state
    setState(() {});
    await _handlePullToRefresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: _stateManager.getCachedNotifications(),
          builder: (context, snapshot) {
            // Handle loading and error states
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Logo and Profile
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
                    child: Text(
                      'Notification',
                      style: AppTextStyle.semibold24,
                    ),
                  ),
                  AppSpacing.v16(),
                  // Tab bar skeleton
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.grey200,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.v16(),
                  // Skeleton loading
                  Expanded(
                    child: NotificationListSkeleton(itemCount: 3),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Logo and Profile
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
                    child: Text(
                      'Notification',
                      style: AppTextStyle.semibold24,
                    ),
                  ),
                  AppSpacing.v16(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: AppColors.grey300,
                          ),
                          AppSpacing.v16(),
                          Text(
                            'Failed to load notifications',
                            style: AppTextStyle.medium16.copyWith(
                              color: AppColors.grey300,
                            ),
                          ),
                          AppSpacing.v8(),
                          Text(
                            'Pull down to try again',
                            style: AppTextStyle.regular14.copyWith(
                              color: AppColors.grey300,
                            ),
                          ),
                          AppSpacing.v24(),
                          ElevatedButton(
                            onPressed: () =>
                                _notificationService.refreshNotifications(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Try Again',
                              style: AppTextStyle.medium14.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final allNotifications = snapshot.data ?? [];
            final unreadNotifications =
                allNotifications.where((n) => !n.isRead).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Logo and Profile
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
                        Expanded(
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.grey300,
                            indicatorColor: AppColors.primary,
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelStyle: AppTextStyle.medium14,
                            unselectedLabelStyle: AppTextStyle.medium14,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'Unread'),
                              Tab(text: 'All'),
                            ],
                          ),
                        ),
                        if (unreadNotifications.isNotEmpty)
                          Builder(builder: (context) {
                            return Visibility(
                              visible: _tabController.index == 0,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: TextButton(
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
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
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
                            ? RefreshIndicator(
                                onRefresh: () async {
                                  // Show temporary loading state
                                  setState(() {});
                                  await _handlePullToRefreshUnread();
                                  setState(() {});
                                },
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? const NotificationListSkeleton(
                                            itemCount: 3)
                                        : Column(
                                            key: const ValueKey(
                                                'unread-content'),
                                            children: unreadNotifications
                                                .map((notification) {
                                              return Column(
                                                children: [
                                                  NotificationCard(
                                                    notification: notification,
                                                    onMarkAsRead: () =>
                                                        _handleMarkAsRead(
                                                            notification.id),
                                                  ),
                                                  if (notification !=
                                                      unreadNotifications.last)
                                                    AppSpacing.v16(),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _handlePullToRefreshUnread,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        230.h,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.mark_email_read_outlined,
                                            size: 48.w,
                                            color: AppColors.grey300,
                                          ),
                                          AppSpacing.v16(),
                                          Text(
                                            'No unread notifications',
                                            style:
                                                AppTextStyle.medium16.copyWith(
                                              color: AppColors.grey300,
                                            ),
                                          ),
                                          AppSpacing.v8(),
                                          Text(
                                            'Pull down to refresh',
                                            style:
                                                AppTextStyle.regular14.copyWith(
                                              color: AppColors.grey300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        // All tab
                        RefreshIndicator(
                          onRefresh: _handlePullToRefreshAll,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? const NotificationListSkeleton(itemCount: 3)
                                  : allNotifications.isNotEmpty
                                      ? Column(
                                          key: const ValueKey('all-content'),
                                          children: allNotifications
                                              .map((notification) {
                                            return Column(
                                              children: [
                                                NotificationCard(
                                                  notification: notification,
                                                  showMarkAsRead:
                                                      !notification.isRead,
                                                  onMarkAsRead: () =>
                                                      _handleMarkAsRead(
                                                          notification.id),
                                                ),
                                                if (notification !=
                                                    allNotifications.last)
                                                  AppSpacing.v16(),
                                              ],
                                            );
                                          }).toList(),
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              230.h,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .notifications_off_outlined,
                                                  size: 48.w,
                                                  color: AppColors.grey300,
                                                ),
                                                AppSpacing.v16(),
                                                Text(
                                                  'No notifications',
                                                  style: AppTextStyle.medium16
                                                      .copyWith(
                                                    color: AppColors.grey300,
                                                  ),
                                                ),
                                                AppSpacing.v8(),
                                                Text(
                                                  'Pull down to refresh',
                                                  style: AppTextStyle.regular14
                                                      .copyWith(
                                                    color: AppColors.grey300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                            ),
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
            );
          },
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
