import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../../app/routes/page_transitions.dart';
import '../../ui/views/dashboard_view.dart';
import '../../ui/views/notification_view.dart';
import '../../ui/views/appointment_view.dart';

// Extension to get the current route name
extension NavigatorStateExtension on NavigatorState {
  String? get currentRouteName {
    String? currentPath;
    popUntil((route) {
      currentPath = route.settings.name;
      return true;
    });
    return currentPath;
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<dynamic>> routeObserver =
      RouteObserver<ModalRoute<dynamic>>();

  static NavigatorState? get _navigatorState => navigatorKey.currentState;

  /// Handle back button/gesture for bottom navigation tabs
  static Future<bool> handleBackPress() {
    final currentRoute = _navigatorState?.currentRouteName;

    // If we're on a tab route that's not dashboard, navigate to dashboard
    if (currentRoute == AppRoutes.notificationView ||
        currentRoute == AppRoutes.appointmentView) {
      pushReplacementNamed(AppRoutes.dashboardView);
      return Future.value(false); // Don't close the app
    }

    // Let the system handle the back press normally
    return Future.value(true);
  }

  /// Navigate to a named route
  static Future<dynamic> pushNamed(String routeName,
      {Object? arguments, bool replace = false}) {
    // Optimize transitions for bottom nav tab routes
    final currentRoute = _navigatorState?.currentRouteName;

    // If we're already on the route and it's a bottom tab route, don't navigate
    if (currentRoute == routeName && _isBottomTabRoute(routeName)) {
      // Return a completed future with null
      return Future.value(null);
    }

    // For tab routes, use fade transition
    if (_isBottomTabRoute(routeName)) {
      final Widget page = _buildPageForRoute(routeName, arguments);
      final PageRouteBuilder route = AppPageTransitions.fadeTransition(
        page,
        settings: RouteSettings(name: routeName, arguments: arguments),
      );

      if (replace) {
        return _navigatorState!.pushReplacement(route);
      } else {
        return _navigatorState!.push(route);
      }
    }

    // For other routes, use normal navigation
    if (replace) {
      return _navigatorState!
          .pushReplacementNamed(routeName, arguments: arguments);
    } else {
      return _navigatorState!.pushNamed(routeName, arguments: arguments);
    }
  }

  /// Navigate to route and remove all previous routes
  static Future<dynamic> pushReplacementNamed(String routeName,
      {Object? arguments}) {
    return pushNamed(routeName, arguments: arguments, replace: true);
  }

  /// Navigate to route and remove all previous routes
  static Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Object? arguments}) {
    // For dashboard, use fade transition
    if (routeName == AppRoutes.dashboardView) {
      final Widget page =
          Dashboard(recentTimesheet: arguments as Map<String, dynamic>?);
      final PageRouteBuilder route = AppPageTransitions.fadeTransition(
        page,
        settings: RouteSettings(name: routeName, arguments: arguments),
      );

      return _navigatorState!.pushAndRemoveUntil(
        route,
        (Route<dynamic> route) => false,
      );
    }

    return _navigatorState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  static void pop({Object? result}) {
    // First check if we're on a bottom tab route that's not dashboard
    final currentRoute = _navigatorState?.currentRouteName;

    if ((currentRoute == AppRoutes.notificationView ||
            currentRoute == AppRoutes.appointmentView) &&
        _navigatorState?.canPop() == true) {
      // If on notification or appointment view, go to dashboard instead of popping
      pushReplacementNamed(AppRoutes.dashboardView);
    } else if (_navigatorState?.canPop() == true) {
      // Otherwise normal pop behavior
      _navigatorState!.pop(result);
    }
  }

  /// Check if we can go back
  static bool canPop() {
    return _navigatorState!.canPop();
  }

  /// Helper to check if a route is a bottom tab route
  static bool _isBottomTabRoute(String routeName) {
    return routeName == AppRoutes.dashboardView ||
        routeName == AppRoutes.notificationView ||
        routeName == AppRoutes.appointmentView;
  }

  /// Helper to build the appropriate page widget for a route
  static Widget _buildPageForRoute(String routeName, Object? arguments) {
    switch (routeName) {
      case AppRoutes.dashboardView:
        return Dashboard(recentTimesheet: arguments as Map<String, dynamic>?);
      case AppRoutes.notificationView:
        return const NotificationView();
      case AppRoutes.appointmentView:
        return const AppointmentView();
      default:
        throw Exception('Unknown route: $routeName');
    }
  }

  // For backwards compatibility
  static void goBack() {
    pop();
  }
}
