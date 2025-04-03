import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// This file provides a way to manually define Firebase options if the
/// automatically generated firebase_options.dart file is not available.
///
/// To use this file:
/// 1. Extract values from your google-services.json and GoogleService-Info.plist
/// 2. Fill in the values below
/// 3. Import this file in main.dart
/// 4. Use FirebaseManualOptions.currentPlatform in Firebase.initializeApp()

class FirebaseManualOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
    }
  }

  // Replace these values with those from your google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: 'YOUR-ANDROID-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'multitenant-interpreter',
    // Optional values
    // authDomain: 'YOUR-AUTH-DOMAIN',
    // storageBucket: 'YOUR-STORAGE-BUCKET',
  );

  // Replace these values with those from your GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'multitenant-interpreter',
    // Optional values
    // authDomain: 'YOUR-AUTH-DOMAIN',
    // storageBucket: 'YOUR-STORAGE-BUCKET',
    // iosClientId: 'YOUR-IOS-CLIENT-ID',
  );
}

/// How to extract values from google-services.json:
/// 
/// apiKey: Look for "api_key" -> "current_key"
/// appId: Look for "client" -> "client_info" -> "mobilesdk_app_id"
/// messagingSenderId: Look for "project_info" -> "project_number"
/// projectId: Look for "project_info" -> "project_id"
/// 
/// How to extract values from GoogleService-Info.plist:
/// 
/// apiKey: Look for "API_KEY"
/// appId: Look for "GOOGLE_APP_ID"
/// messagingSenderId: Look for "GCM_SENDER_ID"
/// projectId: Look for "PROJECT_ID"
/// iosClientId: Look for "CLIENT_ID" 