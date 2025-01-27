import 'package:flutter/material.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_icons.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';

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

  Future<void> _handleNavigation(BuildContext context, int index) async {
    if (index == widget.currentIndex) return;

    // Prevent rapid taps (debounce)
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
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
              color: widget.currentIndex == 0 ? AppColors.primary : AppColors.grey300,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: AppIcons(
              icon: AppIconData.notification,
              color: widget.currentIndex == 1 ? AppColors.primary : AppColors.grey300,
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: AppIcons(
              icon: AppIconData.calendar,
              color: widget.currentIndex == 2 ? AppColors.primary : AppColors.grey300,
            ),
            label: 'Appointment',
          ),
        ],
      ),
    );
  }
}
