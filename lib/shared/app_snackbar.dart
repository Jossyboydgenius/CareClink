import 'package:flutter/material.dart';
import '../data/services/navigator_service.dart';

class AppSnackbar {
  static void showSnackBar({
    required String message,
    Color? color,
  }) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color ?? Colors.green,
          content: Text(
            message,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
    }
  }

  static showErrorSnackBar({required String message}) {
    showSnackBar(message: message, color: Colors.red);
  }
} 