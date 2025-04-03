import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import '../../shared/app_colors.dart';
import '../../shared/app_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';
import '../../app/locator.dart';
import '../../data/services/notification_service.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool _isNavigating = false;
  DateTime? _lastTap;
  final NotificationService _notificationService =
      locator<NotificationService>();

  @override
  void initState() {
    super.initState();
    // Set up a listener to rebuild the widget when notifications change
    _notificationService.notificationsStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleNavigation(BuildContext context, int index) async {
    if (index == widget.currentIndex) return;

    // Prevent rapid taps (debounce)
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastTap = now;

    // Prevent multiple navigations at once
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      String targetRoute;
      switch (index) {
        case 0:
          targetRoute = AppRoutes.dashboardView;
          await NavigationService.closeAllAndPushNamed(targetRoute);
          break;
        case 1:
          targetRoute = AppRoutes.notificationView;
          await NavigationService.pushNamed(targetRoute);
          break;
        case 2:
          targetRoute = AppRoutes.appointmentView;
          await NavigationService.pushNamed(targetRoute);
          break;
        default:
          _isNavigating = false;
          return;
      }

      if (mounted) {
        widget.onTap(index);
      }
    } finally {
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notificationService.getUnreadCount();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) => _handleNavigation(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey300,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: AppIcons(
              icon: AppIconData.dashboard,
              size: 20,
              color: widget.currentIndex == 0
                  ? AppColors.primary
                  : AppColors.grey300,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: unreadCount > 0,
              position: badges.BadgePosition.topEnd(top: -8, end: -6),
              badgeContent: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(4),
              ),
              child: AppIcons(
                icon: AppIconData.notification,
                color: widget.currentIndex == 1
                    ? AppColors.primary
                    : AppColors.grey300,
              ),
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: AppIcons(
              icon: AppIconData.calendar,
              color: widget.currentIndex == 2
                  ? AppColors.primary
                  : AppColors.grey300,
            ),
            label: 'Appointment',
          ),
        ],
      ),
    );
  }
}
