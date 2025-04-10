import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// Import flutter_local_notifications conditionally
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../app/locator.dart';
import '../models/notification_model.dart';
import 'local_storage_service.dart';
import 'api/api.dart';
import 'notification_api_service.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase for background handlers
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final Api _api = locator<Api>();
  final NotificationApiService _notificationApiService =
      locator<NotificationApiService>();

  static const String FCM_TOKEN_KEY = 'fcm_token';

  // Local notifications setup - commented out due to dependency issues
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
  //   'high_importance_channel',
  //   'High Importance Notifications',
  //   description: 'This channel is used for important notifications.',
  //   importance: Importance.high,
  // );

  // Initialize notification channels and request permission
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
          'User granted notification permission: ${settings.authorizationStatus}');

      // Initialize local notifications - commented out due to dependency issues
      // try {
      //   const AndroidInitializationSettings initializationSettingsAndroid =
      //       AndroidInitializationSettings('@mipmap/ic_launcher');

      //   final DarwinInitializationSettings initializationSettingsIOS =
      //       DarwinInitializationSettings(
      //     requestAlertPermission: true,
      //     requestBadgePermission: true,
      //     requestSoundPermission: true,
      //     onDidReceiveLocalNotification:
      //         (int id, String? title, String? body, String? payload) async {
      //       // Handle iOS foreground notification
      //     },
      //   );

      //   final InitializationSettings initializationSettings =
      //       InitializationSettings(
      //     android: initializationSettingsAndroid,
      //     iOS: initializationSettingsIOS,
      //   );

      //   await _flutterLocalNotificationsPlugin.initialize(
      //     initializationSettings,
      //     onDidReceiveNotificationResponse:
      //         (NotificationResponse notificationResponse) async {
      //       // Handle notification tap
      //       final String? payload = notificationResponse.payload;
      //       if (payload != null) {
      //         debugPrint('Notification payload: $payload');
      //         // Handle payload (e.g., navigate to specific screen)
      //       }
      //     },
      //   );

      //   // Create Android notification channel
      //   await _flutterLocalNotificationsPlugin
      //       .resolvePlatformSpecificImplementation<
      //           AndroidFlutterLocalNotificationsPlugin>()
      //       ?.createNotificationChannel(_channel);

      //   debugPrint('Local notifications initialized successfully');
      // } catch (e) {
      //   debugPrint('Error initializing local notifications: $e');
      //   debugPrint('App will continue without local notification support');
      //   // App can still function with FCM but without local notifications
      // }

      // Get initial token
      await getAndUpdateFcmToken();

      // Setup token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM token refreshed: $newToken');
        _updateFcmToken(newToken);
      });

      // Setup foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Setup background/terminated message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Fetch initial notifications from server - force refresh to ensure we have the latest data
      await _notificationApiService.fetchNotifications(force: true);

      debugPrint('Firebase Cloud Messaging fully initialized');
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  // Handle foreground messages with error handling - simplified without local notifications
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Received foreground message: ${message.notification?.title}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Create notification model from FCM message
      final notificationModel = NotificationModel.fromFcm({
        'id': message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'title': notification?.title ?? 'New Notification',
        'message': notification?.body ?? '',
        'type': message.data['type'] ?? 'General',
      });

      // Add the notification to our notification service and refresh from server
      _notificationApiService.addNotification(notificationModel);

      // Force refresh to get latest data from server
      refreshNotifications();

      // Local notifications showing is commented out due to dependency issues
      // if (notification != null && android != null) {
      //   try {
      //     _flutterLocalNotificationsPlugin.show(
      //       notification.hashCode,
      //       notification.title,
      //       notification.body,
      //       NotificationDetails(
      //         android: AndroidNotificationDetails(
      //           _channel.id,
      //           _channel.name,
      //           channelDescription: _channel.description,
      //           icon: android.smallIcon,
      //         ),
      //         iOS: const DarwinNotificationDetails(),
      //       ),
      //       payload: json.encode(message.data),
      //     );
      //   } catch (e) {
      //     debugPrint('Error showing local notification: $e');
      //   }
      // }

      debugPrint('Notification added to service: ${notificationModel.title}');
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  // Get the current token and update it on the server
  Future<String?> getAndUpdateFcmToken() async {
    try {
      String? storedToken =
          await _storageService.getStorageValue(FCM_TOKEN_KEY);
      String? currentToken = await _firebaseMessaging.getToken();

      debugPrint('FCM Token: $currentToken');

      if (currentToken != null && currentToken != storedToken) {
        await _updateFcmToken(currentToken);
      }

      return currentToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Update token on server and store it locally
  Future<void> _updateFcmToken(String token) async {
    try {
      debugPrint('Updating FCM token on server: $token');

      // Save token to local storage first
      await _storageService.saveStorageValue(FCM_TOKEN_KEY, token);

      // Send token to server
      final response = await _api.putData(
        '/user/fcm-token',
        {"token": token},
        hasHeader: true,
      );

      if (response.isSuccessful) {
        debugPrint('FCM token updated successfully on server');
      } else {
        debugPrint('Failed to update FCM token on server: ${response.message}');
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Delete token from server and local storage
  Future<void> deleteToken() async {
    try {
      // Delete token from local storage
      await _storageService.fSStorage.delete(key: FCM_TOKEN_KEY);

      // Delete token from FirebaseMessaging
      await _firebaseMessaging.deleteToken();

      debugPrint('FCM token deleted successfully');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  // Get the notification stream for UI components to listen to
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationApiService.notificationsStream;

  // Get unread notification count
  int getUnreadCount() => _notificationApiService.getUnreadCount();

  // Get unread notifications
  List<NotificationModel> getUnreadNotifications() =>
      _notificationApiService.getUnreadNotifications();

  // Force refresh notifications from server
  Future<void> refreshNotifications() async {
    await _notificationApiService.fetchNotifications(force: true);
  }

  // Force refresh unread notifications from server
  Future<void> fetchUnreadNotifications({bool force = true}) async {
    await _notificationApiService.fetchUnreadNotifications(force: force);
  }

  // Mark a single notification as read
  Future<bool> markAsRead(String id) async {
    return await _notificationApiService.markAsRead(id);
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    return await _notificationApiService.markAllAsRead();
  }
}
