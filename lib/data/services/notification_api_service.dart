import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/notification_model.dart';
import 'api/api.dart';
import 'mock_notification_service.dart';
import 'dart:async';

class NotificationApiService {
  final Api _api = locator<Api>();

  // Controller for broadcasting notification updates
  final _notificationsStreamController =
      StreamController<List<NotificationModel>>.broadcast();

  // Stream that UI components can listen to
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsStreamController.stream;

  // Cache for notifications to reduce API calls
  List<NotificationModel> _cachedNotifications = [];

  // Last fetch time to implement polling with throttling
  DateTime? _lastFetchTime;
  Timer? _pollingTimer;
  bool _isFetching = false;

  NotificationApiService() {
    // Load initial mock data if available
    _cachedNotifications = MockNotificationService.getAllNotifications();
    _notificationsStreamController.add(_cachedNotifications);

    // Setup polling for new notifications
    _startPolling();
  }

  void _startPolling() {
    // Poll every 30 seconds for new notifications
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchNotifications(force: false);
    });
  }

  void dispose() {
    _pollingTimer?.cancel();
    _notificationsStreamController.close();
  }

  // Fetch notifications from API with throttling
  Future<List<NotificationModel>> fetchNotifications(
      {bool force = true}) async {
    // If we're already fetching or it hasn't been 10 seconds since last fetch (unless forced)
    if (_isFetching ||
        (!force &&
            _lastFetchTime != null &&
            DateTime.now().difference(_lastFetchTime!).inSeconds < 10)) {
      return _cachedNotifications;
    }

    _isFetching = true;

    try {
      final response = await _api.getData(
        '/notifications',
        hasHeader: true,
      );

      _lastFetchTime = DateTime.now();

      if (response.isSuccessful && response.data != null) {
        final List<dynamic> notificationsJson =
            response.data['notifications'] ?? [];

        // Convert API data to NotificationModel objects
        final List<NotificationModel> serverNotifications =
            notificationsJson.map((json) {
          return NotificationModel(
            id: json['id'] ??
                json['_id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: json['title'] ?? 'New Notification',
            message: json['message'] ?? json['body'] ?? '',
            type: json['type'] ?? 'General',
            timestamp: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            isRead: json['isRead'] ?? false,
          );
        }).toList();

        // Merge with any local notifications (such as those from FCM)
        _mergeNotifications(serverNotifications);

        // Broadcast the updated list to all listeners
        _notificationsStreamController.add(_cachedNotifications);

        return _cachedNotifications;
      }

      debugPrint('Error fetching notifications: ${response.message}');
      return _cachedNotifications;
    } catch (e) {
      debugPrint('Exception fetching notifications: $e');
      return _cachedNotifications;
    } finally {
      _isFetching = false;
    }
  }

  // Merge local and server notifications while preserving local unread status
  void _mergeNotifications(List<NotificationModel> serverNotifications) {
    // Create a map of existing notifications by ID for quick lookup
    final Map<String, NotificationModel> existingNotificationsMap = {
      for (var notification in _cachedNotifications)
        notification.id: notification
    };

    // Update existing notifications and add new ones
    for (var serverNotification in serverNotifications) {
      if (existingNotificationsMap.containsKey(serverNotification.id)) {
        // If we already have this notification locally, preserve its read status
        final existingNotification =
            existingNotificationsMap[serverNotification.id]!;
        serverNotification.isRead = existingNotification.isRead;
      }

      existingNotificationsMap[serverNotification.id] = serverNotification;
    }

    // Convert map back to list and sort by timestamp (newest first)
    _cachedNotifications = existingNotificationsMap.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() {
    return _cachedNotifications
        .where((notification) => !notification.isRead)
        .toList();
  }

  // Get all notifications
  List<NotificationModel> getAllNotifications() {
    return _cachedNotifications;
  }

  // Get unread notification count
  int getUnreadCount() {
    return getUnreadNotifications().length;
  }

  // Mark a notification as read
  Future<bool> markAsRead(String id) async {
    try {
      // Find notification in the cache
      final notification = _cachedNotifications.firstWhere(
        (notification) => notification.id == id,
        orElse: () => throw Exception('Notification not found'),
      );

      // If it's already read, do nothing
      if (notification.isRead) return true;

      // Update locally first for immediate UI feedback
      notification.isRead = true;
      _notificationsStreamController.add(_cachedNotifications);

      // Then update on the server
      final response = await _api.postData(
        '/notifications/$id/read',
        {},
        hasHeader: true,
      );

      return response.isSuccessful;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      // Update locally first for immediate UI feedback
      for (var notification in _cachedNotifications) {
        notification.isRead = true;
      }

      _notificationsStreamController.add(_cachedNotifications);

      // Then update on the server
      final response = await _api.postData(
        '/notifications/read-all',
        {},
        hasHeader: true,
      );

      return response.isSuccessful;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Add a new notification (typically from FCM)
  void addNotification(NotificationModel notification) {
    _cachedNotifications.insert(0, notification);
    _notificationsStreamController.add(_cachedNotifications);
  }
}
