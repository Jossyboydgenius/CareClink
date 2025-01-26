import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../app/routes/app_routes.dart';

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
      final currentRoute = ModalRoute.of(context)?.settings.name;
      String targetRoute;

      switch (index) {
        case 0:
          targetRoute = AppRoutes.dashboardView;
          break;
        case 1:
          targetRoute = AppRoutes.notificationView;
          break;
        case 2:
          targetRoute = AppRoutes.appointmentView;
          break;
        default:
          _isNavigating = false;
          return;
      }

      if (currentRoute == targetRoute) {
        _isNavigating = false;
        return;
      }

      if (index == 0) {
        await Navigator.of(context).pushNamedAndRemoveUntil(
          targetRoute,
          (route) => false,
        );
      } else {
        if (currentRoute == AppRoutes.dashboardView) {
          await Navigator.of(context).pushNamed(targetRoute);
        } else {
          await Navigator.of(context).pushReplacementNamed(targetRoute);
        }
      }
      widget.onTap(index);
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) => _handleNavigation(context, index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey300,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
              size: 24.w,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              size: 24.w,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 24.w,
                ),
                if (widget.currentIndex != 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12.w,
                        minHeight: 12.w,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  size: 24.w,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12.w,
                      minHeight: 12.w,
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today_outlined,
              size: 24.w,
            ),
            activeIcon: Icon(
              Icons.calendar_today,
              size: 24.w,
            ),
            label: 'Appointment',
          ),
        ],
      ),
    );
  }
}
