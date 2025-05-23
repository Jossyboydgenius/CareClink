import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -10, end: -12),
        badgeContent: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
          padding: EdgeInsets.all(4),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          size: 28,
          color: Colors.black,
        ),
      ),
    );
  }
} 