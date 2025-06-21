import '../data/services/notification_service.dart';
import '../data/services/appointment_service.dart';
import '../data/models/appointment_model.dart';
import '../data/models/notification_model.dart';
import 'locator.dart';

/// A class that manages navigation state persistence across the app
/// to prevent unnecessary API calls when switching bottom navigation tabs
class NavigationStateManager {
  static final NavigationStateManager _instance =
      NavigationStateManager._internal();
  factory NavigationStateManager() => _instance;
  NavigationStateManager._internal();

  // Tracking when services were last refreshed
  DateTime? _lastNotificationRefresh;
  DateTime? _lastAppointmentRefresh;
  DateTime? _lastDashboardRefresh;

  // Access to services
  final NotificationService _notificationService =
      locator<NotificationService>();
  final AppointmentService _appointmentService = locator<AppointmentService>();

  // Cache for the data
  List<NotificationModel>? _cachedNotifications;
  List<AppointmentModel>? _cachedAppointments;
  bool _isLoadingNotifications = false;
  bool _isLoadingAppointments = false;

  /// The refresh threshold in minutes - only refresh if last refresh was longer than this
  static const int refreshThresholdMinutes = 5;

  /// Reset all refresh timestamps, forcing a complete refresh on next navigation
  void resetAllRefreshTimestamps() {
    _lastNotificationRefresh = null;
    _lastAppointmentRefresh = null;
    _lastDashboardRefresh = null;
    _cachedNotifications = null;
    _cachedAppointments = null;
  }

  /// Check if notifications need to be refreshed
  /// Returns true if they should be refreshed
  bool shouldRefreshNotifications() {
    if (_lastNotificationRefresh == null) return true;
    return DateTime.now().difference(_lastNotificationRefresh!).inMinutes >
        refreshThresholdMinutes;
  }

  /// Check if appointments need to be refreshed
  /// Returns true if they should be refreshed
  bool shouldRefreshAppointments() {
    if (_lastAppointmentRefresh == null) return true;
    return DateTime.now().difference(_lastAppointmentRefresh!).inMinutes >
        refreshThresholdMinutes;
  }

  /// Check if dashboard needs to be refreshed
  /// Returns true if it should be refreshed
  bool shouldRefreshDashboard() {
    if (_lastDashboardRefresh == null) return true;
    return DateTime.now().difference(_lastDashboardRefresh!).inMinutes >
        refreshThresholdMinutes;
  }

  /// Get cached notifications or load them if needed
  Stream<List<NotificationModel>> getCachedNotifications() {
    // If not loaded or needs refreshing, refresh the notifications
    if (_cachedNotifications == null || shouldRefreshNotifications()) {
      refreshNotificationsIfNeeded();
    }

    // Return the stream from the service - it will be updated when loaded
    return _notificationService.notificationsStream;
  }

  /// Get only unread notifications
  Future<List<NotificationModel>> getCachedUnreadNotifications() async {
    // If we need to refresh, fetch unread notifications specifically
    if (shouldRefreshNotifications()) {
      await _notificationService.fetchUnreadNotifications(force: true);
      _lastNotificationRefresh = DateTime.now();
    }

    // Return the unread notifications
    return _notificationService.getUnreadNotifications();
  }

  /// Get cached appointments or load them if needed
  Future<List<AppointmentModel>> getCachedAppointments() async {
    // If loading is in progress, wait for it
    if (_isLoadingAppointments) {
      await Future.delayed(const Duration(milliseconds: 100));
      return getCachedAppointments();
    }

    // If data is cached and doesn't need refreshing, return it
    if (_cachedAppointments != null && !shouldRefreshAppointments()) {
      return _cachedAppointments!;
    }

    // Otherwise load the data
    return _refreshAppointments();
  }

  /// Refresh notifications if needed
  Future<void> refreshNotificationsIfNeeded() async {
    if (_isLoadingNotifications) {
      return; // Prevent multiple simultaneous refresh attempts
    }

    if (shouldRefreshNotifications()) {
      _isLoadingNotifications = true;
      try {
        await _notificationService.refreshNotifications();
        _lastNotificationRefresh = DateTime.now();
      } finally {
        _isLoadingNotifications = false;
      }
    }
  }

  /// Force refresh notifications
  Future<void> forceRefreshNotifications() async {
    _isLoadingNotifications = true;
    try {
      await _notificationService.refreshNotifications();
      _lastNotificationRefresh = DateTime.now();
    } finally {
      _isLoadingNotifications = false;
    }
  }

  /// Force refresh unread notifications only
  Future<void> forceRefreshUnreadNotifications() async {
    _isLoadingNotifications = true;
    try {
      await _notificationService.fetchUnreadNotifications(force: true);
      _lastNotificationRefresh = DateTime.now();
    } finally {
      _isLoadingNotifications = false;
    }
  }

  /// Refresh appointments if needed
  Future<void> refreshAppointmentsIfNeeded() async {
    if (_isLoadingAppointments) {
      return; // Prevent multiple simultaneous refresh attempts
    }

    if (shouldRefreshAppointments()) {
      await getCachedAppointments(); // This will refresh the appointments
    }
  }

  /// Refresh appointments and return the result
  Future<List<AppointmentModel>> _refreshAppointments() async {
    _isLoadingAppointments = true;
    try {
      final appointments = await _appointmentService.getTodayAppointments();
      _cachedAppointments = appointments;
      _lastAppointmentRefresh = DateTime.now();
      return appointments;
    } finally {
      _isLoadingAppointments = false;
    }
  }

  /// Mark dashboard as refreshed
  void markDashboardRefreshed() {
    _lastDashboardRefresh = DateTime.now();
  }

  /// Mark notifications as refreshed (called after a manual refresh)
  void markNotificationsRefreshed() {
    _lastNotificationRefresh = DateTime.now();
  }

  /// Mark appointments as refreshed (called after a manual refresh)
  void markAppointmentsRefreshed() {
    _lastAppointmentRefresh = DateTime.now();
  }

  /// Force refresh appointments
  Future<List<AppointmentModel>> forceRefreshAppointments() async {
    _isLoadingAppointments = true;
    try {
      final appointments = await _appointmentService.getTodayAppointments();
      _cachedAppointments = appointments;
      _lastAppointmentRefresh = DateTime.now();
      return appointments;
    } finally {
      _isLoadingAppointments = false;
    }
  }
}
