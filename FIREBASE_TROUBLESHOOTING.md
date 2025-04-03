# Firebase Troubleshooting Guide

If you're encountering issues with Firebase initialization or FCM in your Flutter app, follow these troubleshooting steps.

## Error: "The method 'getUnreadNotifications' isn't defined for the type 'NotificationService'"

This error occurs because you're trying to use a method from `MockNotificationService` but importing `NotificationService`. 

**Solution:** 
- Make sure to import `mock_notification_service.dart` instead of `notification_service.dart` in files that use methods like `getUnreadNotifications()`
- Update imports at the top of your file:
  ```dart
  import '../../data/services/mock_notification_service.dart';
  ```

## Firebase Initialization Errors

### 1. Default Initialization Issues

If you encounter errors when initializing Firebase with the default method, try using explicit options:

```dart
// In main.dart
import 'firebase_manual_options.dart';

// Then replace
await Firebase.initializeApp();

// With
await Firebase.initializeApp(
  options: FirebaseManualOptions.currentPlatform,
);
```

### 2. Missing Configuration Files

Make sure your configuration files are in the correct locations:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

You can verify this with:
```bash
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
```

### 3. Incorrect Firebase Plugin Configuration

For Android, ensure these changes are made:

In `android/build.gradle`:
```gradle
buildscript {
  dependencies {
    // ... other dependencies
    classpath 'com.google.gms:google-services:4.4.1'
  }
}
```

In `android/app/build.gradle`, at the end of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Firebase Initialization Debugging

Add more detailed error logging for Firebase initialization:

```dart
try {
  await Firebase.initializeApp();
  debugPrint('Firebase initialized successfully');
} catch (e) {
  debugPrint('Error initializing Firebase: $e');
  // Try with explicit options as a fallback
  try {
    await Firebase.initializeApp(
      options: FirebaseManualOptions.currentPlatform,
    );
    debugPrint('Firebase initialized with explicit options');
  } catch (e2) {
    debugPrint('Fatal error initializing Firebase: $e2');
  }
}
```

### 5. Using FlutterFire CLI

The recommended way to set up Firebase is using the FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your app
flutterfire configure --project=your-firebase-project-id
```

This will automatically generate `firebase_options.dart` for you.

## FCM Token Issues

### 1. Permissions

Ensure you're requesting necessary permissions:

```dart
NotificationSettings settings = await _firebaseMessaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
);
debugPrint('Permission status: ${settings.authorizationStatus}');
```

### 2. Token Generation

If FCM token is not being generated, add more logging:

```dart
String? token = await FirebaseMessaging.instance.getToken();
debugPrint('FCM Token: $token');
```

### 3. Network Issues

Make sure your app has proper internet permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 4. API Endpoint Issues

When updating your token to the server, check the API response:

```dart
final response = await _api.putData(
  '/user/fcm-token',
  {"token": token},
  hasHeader: true,
);
debugPrint('API Response: ${response.statusCode} - ${response.body}');
```

## Firebase Admin SDK Credentials

Remember that the Firebase Admin SDK credentials (the JSON file with service account information) are for server-side use only. These should never be included in your Flutter app.

The flow should be:
1. App gets FCM token from Firebase
2. App sends token to your server
3. Server stores token
4. Server uses Admin SDK to send notifications to that token

## Still Having Issues?

1. Check Firebase console logs for any errors
2. Ensure all packages are up to date:
   ```bash
   flutter pub get
   flutter pub upgrade
   ```
3. Try a clean build:
   ```bash
   flutter clean
   flutter pub get
   ```
4. Check the Firebase documentation for any changes to their APIs 