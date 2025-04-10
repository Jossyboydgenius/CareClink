import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import '../models/notification_model.dart';
import 'api/api.dart';
import 'dart:async';
import 'user_service.dart';

class NotificationApiService {
  final Api _api = locator<Api>();
  final UserService _userService = locator<UserService>();

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
  String? _userId;

  NotificationApiService() {
    // Initialize with empty list
    _cachedNotifications = [];
    _notificationsStreamController.add(_cachedNotifications);

    // Setup polling for new notifications
    _startPolling();

    // Get user ID for API calls
    _initUserId();
  }

  Future<void> _initUserId() async {
    final userData = await _userService.getCurrentUser();
    _userId = userData['userId'];
    debugPrint('Initialized notification service with userId: $_userId');
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

    // Ensure we have the user ID
    if (_userId == null) {
      await _initUserId();
      if (_userId == null) {
        debugPrint('Cannot fetch notifications: Missing user ID');
        return _cachedNotifications;
      }
    }

    _isFetching = true;

    try {
      // Fetch all messages using the API endpoint for all messages
      final response = await _api.getData(
        '/interpreter/messages/all/$_userId',
        hasHeader: true,
      );

      _lastFetchTime = DateTime.now();

      if (response.isSuccessful && response.data != null) {
        final List<dynamic> messagesJson = response.data['messages'] ?? [];
        debugPrint('Fetched ${messagesJson.length} notifications from server');

        // Convert API data to NotificationModel objects
        final List<NotificationModel> serverNotifications =
            messagesJson.map((json) {
          return NotificationModel(
            id: json['_id'] ??
                json['id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: json['title'] ?? json['subject'] ?? 'New Message',
            message: json['message'] ?? json['content'] ?? '',
            type: json['type'] ?? 'Message',
            timestamp: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            isRead: json['isRead'] ?? false,
          );
        }).toList();

        // Replace cached notifications with server data
        _cachedNotifications = serverNotifications;

        // Sort by timestamp (newest first)
        _cachedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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

  // Fetch only unread notifications
  Future<List<NotificationModel>> fetchUnreadNotifications(
      {bool force = true}) async {
    // If we're already fetching or it hasn't been 10 seconds since last fetch (unless forced)
    if (_isFetching ||
        (!force &&
            _lastFetchTime != null &&
            DateTime.now().difference(_lastFetchTime!).inSeconds < 10)) {
      return getUnreadNotifications();
    }

    // Ensure we have the user ID
    if (_userId == null) {
      await _initUserId();
      if (_userId == null) {
        debugPrint('Cannot fetch unread notifications: Missing user ID');
        return getUnreadNotifications();
      }
    }

    _isFetching = true;

    try {
      // Use the specific endpoint for unread messages
      final response = await _api.getData(
        '/interpreter/messages/unread/$_userId',
        hasHeader: true,
      );

      _lastFetchTime = DateTime.now();

      if (response.isSuccessful && response.data != null) {
        final List<dynamic> messagesJson = response.data['messages'] ?? [];
        debugPrint(
            'Fetched ${messagesJson.length} unread notifications from server');

        // Convert API data to NotificationModel objects
        final List<NotificationModel> unreadNotifications =
            messagesJson.map((json) {
          return NotificationModel(
            id: json['_id'] ??
                json['id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: json['title'] ?? json['subject'] ?? 'New Message',
            message: json['message'] ?? json['content'] ?? '',
            type: json['type'] ?? 'Message',
            timestamp: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            isRead: false, // These are explicitly unread
          );
        }).toList();

        // Update only the unread notifications in the cache
        // We need to maintain the full list of notifications, so we'll merge
        _mergeUnreadNotifications(unreadNotifications);

        // Broadcast the updated list to all listeners
        _notificationsStreamController.add(_cachedNotifications);

        // Return only the unread notifications
        return getUnreadNotifications();
      }

      debugPrint('Error fetching unread notifications: ${response.message}');
      return getUnreadNotifications();
    } catch (e) {
      debugPrint('Exception fetching unread notifications: $e');
      return getUnreadNotifications();
    } finally {
      _isFetching = false;
    }
  }

  // Helper to merge unread notifications with the cached full list
  void _mergeUnreadNotifications(List<NotificationModel> unreadNotifications) {
    // Create a map of existing notifications by ID for quick lookup
    final Map<String, NotificationModel> existingNotificationsMap = {
      for (var notification in _cachedNotifications)
        notification.id: notification
    };

    // Add or update unread notifications
    for (var unreadNotification in unreadNotifications) {
      existingNotificationsMap[unreadNotification.id] = unreadNotification;
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

  // Fetch read notifications
  Future<List<NotificationModel>> fetchReadNotifications(
      {bool force = true}) async {
    // Ensure we have the user ID
    if (_userId == null) {
      await _initUserId();
      if (_userId == null) {
        debugPrint('Cannot fetch read notifications: Missing user ID');
        return [];
      }
    }

    // Use the specific endpoint for read messages
    final response = await _api.getData(
      '/interpreter/messages/isread/$_userId',
      hasHeader: true,
    );

    if (response.isSuccessful && response.data != null) {
      final List<dynamic> messagesJson = response.data['messages'] ?? [];
      debugPrint(
          'Fetched ${messagesJson.length} read notifications from server');

      // Convert API data to NotificationModel objects
      return messagesJson.map((json) {
        return NotificationModel(
          id: json['_id'] ??
              json['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: json['title'] ?? json['subject'] ?? 'New Message',
          message: json['message'] ?? json['content'] ?? '',
          type: json['type'] ?? 'Message',
          timestamp: json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
          isRead: true, // These are explicitly read
        );
      }).toList();
    }

    return [];
  }

  // Get all notifications
  List<NotificationModel> getAllNotifications() {
    return _cachedNotifications;
  }

  // Get unread notification count
  int getUnreadCount() {
    // If we encountered errors loading notifications, or we have an empty cache
    // and never successfully loaded, return 0 to hide the badge
    if (_cachedNotifications.isEmpty && _lastFetchTime == null) {
      return 0;
    }
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

      // Then update on the server using the new API endpoint
      final response = await _api.putData(
        '/interpreter/messages/mark-read/$id',
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
    // Ensure we have the user ID
    if (_userId == null) {
      await _initUserId();
      if (_userId == null) {
        debugPrint('Cannot mark all as read: Missing user ID');
        return false;
      }
    }

    try {
      // Update locally first for immediate UI feedback
      for (var notification in _cachedNotifications) {
        notification.isRead = true;
      }

      _notificationsStreamController.add(_cachedNotifications);

      // Then update on the server using the new API endpoint
      final response = await _api.putData(
        '/interpreter/messages/markall-asread/$_userId',
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
