# Firebase Cloud Messaging Setup

This guide explains how to set up Firebase Cloud Messaging (FCM) for the CareClink app.

## Prerequisites

Make sure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.27.1
  firebase_messaging: ^14.8.15
  flutter_local_notifications: ^16.3.0
```

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use an existing one)
3. Follow the setup wizard to create your project

### 2. Android Setup

1. Register your Android app with Firebase:
   - Package name: `com.careclink.app` (or your actual package name)
   - App nickname: "CareClink"
   - Debug signing certificate: Optional for development

2. Download the `google-services.json` file and place it in:
   ```
   android/app/google-services.json
   ```

3. Ensure your Android project is configured for Firebase by adding these dependencies:

   In `android/build.gradle`:
   ```gradle
   buildscript {
     dependencies {
       // ... other dependencies
       classpath 'com.google.gms:google-services:4.4.1'
     }
   }
   ```

   In `android/app/build.gradle`:
   ```gradle
   // At the bottom of the file
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. iOS Setup

1. Register your iOS app with Firebase:
   - Bundle ID: `com.careclink.app` (or your actual bundle ID)
   - App nickname: "CareClink"

2. Download the `GoogleService-Info.plist` file

3. Add the file to your Xcode project:
   - Open Xcode with `open ios/Runner.xcworkspace`
   - Right-click on the Runner project in the navigator
   - Select "Add Files to 'Runner'"
   - Select the downloaded `GoogleService-Info.plist` file
   - Make sure "Copy items if needed" is checked
   - Add to targets: Runner
   - Click "Add"

## Testing FCM

To test that FCM is working correctly:

1. Start the app and check the logs for the message "FCM Token: [your-token]"
2. Send a test message from the Firebase console:
   - Go to Firebase Console > Your Project > Messaging
   - Create a new campaign or send a test message
   - Use the FCM token printed in the console
   - The app should receive the notification

## Troubleshooting

- Ensure you've updated the AndroidManifest.xml with the required permissions
- For iOS, ensure you have enabled push notification capabilities in Xcode
- Check the app logs for any Firebase-related errors
- Verify that your device or emulator has Google Play Services installed 