# Firebase Admin SDK Setup

The provided Firebase service account credentials are for server-side use only. These credentials give administrative access to your Firebase project and should never be included in your client-side Flutter app code.

## Understanding the Service Account Credentials

The JSON file provided contains private credentials that allow a server to authenticate with Firebase services with administrative privileges. This is different from the client-side configuration files (`google-services.json` and `GoogleService-Info.plist`) needed for the Flutter app.

## How to Use the Firebase Admin SDK Credentials

These credentials should be used on your backend server to:

1. Send push notifications to specific devices or topics
2. Manage user accounts
3. Access Firebase services with administrative privileges

### Setting Up a Server to Send Push Notifications

1. Store the provided JSON credentials securely on your server (never in your Flutter app or public repositories)
2. Use the credentials to initialize the Firebase Admin SDK on your server
3. Use the Admin SDK to send push notifications to your app users

Example of a Node.js server using these credentials:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path-to-your-credentials.json'); // Your downloaded credentials

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Function to send a notification to a specific device token
async function sendNotification(deviceToken, title, body, data = {}) {
  try {
    const message = {
      token: deviceToken,
      notification: {
        title: title,
        body: body,
      },
      data: data
    };
    
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
}
```

## What Your Flutter App Needs

Your Flutter app only needs:

1. The Firebase configuration files for each platform:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

2. The FCM token update functionality which is already implemented in your app to send tokens to your API endpoint:
   ```dart
   Future<void> _updateFcmToken(String token) async {
     // This sends the token to your backend API
     final response = await _api.putData(
       '/user/fcm-token',
       {"token": token},
       hasHeader: true,
     );
   }
   ```

## Server-Client Flow for Push Notifications

1. Your Flutter app receives an FCM token from Firebase
2. Your app sends this token to your server API (`/user/fcm-token`)
3. Your server stores this token in a database, associated with the user
4. When your server needs to send a notification to a specific user:
   - It retrieves the user's FCM token
   - It uses the Firebase Admin SDK (initialized with the provided credentials) to send the notification
   - The notification is delivered to the device with that FCM token

## Security Recommendations

1. **Never** include the service account credentials in your mobile app
2. Store the credentials securely on your server with appropriate access controls
3. Set up proper authentication for your API endpoints
4. Use HTTPS for all communication between your app and server 