import 'package:flutter/material.dart';
import '../../shared/app_sizer.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: AppDimension.getFontSize(12),
        unselectedFontSize: AppDimension.getFontSize(12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
              size: AppDimension.getWidth(24),
            ),
            activeIcon: Icon(
              Icons.dashboard,
              size: AppDimension.getWidth(24),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: AppDimension.getWidth(24),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppDimension.getWidth(2)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: AppDimension.getWidth(12),
                      minHeight: AppDimension.getWidth(12),
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppDimension.getFontSize(8),
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
                  size: AppDimension.getWidth(24),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(AppDimension.getWidth(2)),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: AppDimension.getWidth(12),
                      minHeight: AppDimension.getWidth(12),
                    ),
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppDimension.getFontSize(8),
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
              size: AppDimension.getWidth(24),
            ),
            activeIcon: Icon(
              Icons.calendar_today,
              size: AppDimension.getWidth(24),
            ),
            label: 'Appointment',
          ),
        ],
      ),
    );
  }
} 