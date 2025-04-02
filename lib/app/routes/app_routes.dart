import 'package:flutter/material.dart';
import '../../ui/views/sign_in_view.dart';
import '../../ui/views/splash_screen_view.dart';
import '../../ui/views/dashboard_view.dart';
import '../../ui/views/notification_view.dart';
import '../../ui/views/appointment_view.dart';

class AppRoutes {
  static const String splashScreenView = '/';
  static const String signInView = '/signIn';
  static const String dashboardView = '/dashboard';
  static const String notificationView = '/notification';
  static const String appointmentView = '/appointment';

  static const String initialRoute = splashScreenView;

  static Map<String, WidgetBuilder> routes = {
    splashScreenView: (context) => const SplashScreen(),
    signInView: (context) => const SignInView(),
    dashboardView: (context) => Dashboard(
      recentTimesheet: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?,
    ),
    notificationView: (context) => const NotificationView(),
    appointmentView: (context) => const AppointmentView(),
  };
} 