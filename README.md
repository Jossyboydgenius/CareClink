# CareClink Mobile App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

## 📱 Overview

CareClink is a comprehensive mobile application designed for interpreter and client management in healthcare settings. The app facilitates appointment scheduling, time tracking, electronic signatures, and visit confirmation through an intuitive mobile interface.

### Key Features

- **Appointment Management** - View, schedule, and manage interpreter appointments
- **Time Tracking** - Clock in/out functionality with automatic timesheet generation
- **Dual Electronic Signatures** - Capture both interpreter and staff signatures for visit confirmation
- **Real-time Notifications** - Stay updated with appointment changes and reminders
- **Visit Reports** - Automatic generation of visit confirmation reports with signatures
- **Offline Support** - Local data caching for seamless offline functionality
- **Secure Authentication** - JWT-based authentication with remember me functionality

---

## 🏗️ Architecture

### Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: BLoC Pattern (flutter_bloc)
- **Networking**: HTTP with custom API wrapper
- **Local Storage**: Flutter Secure Storage
- **Dependency Injection**: GetIt
- **Routing**: Named routes with custom navigation service

### Project Structure

```
lib/
├── app/
│   ├── locator.dart              # Dependency injection setup
│   ├── navigation_state_manager.dart  # App-wide navigation state
│   ├── flavor_config.dart        # Environment configuration
│   └── routes/
│       ├── app_routes.dart       # Route definitions
│       └── page_transitions.dart # Custom page transitions
├── data/
│   ├── models/                   # Data models
│   ├── services/                 # Business logic services
│   │   ├── api/                  # API communication layer
│   │   ├── signature_service.dart
│   │   ├── appointment_service.dart
│   │   ├── timesheet_service.dart
│   │   └── user_service.dart
│   └── utils/                    # Utility functions
├── shared/
│   ├── app_colors.dart          # Color palette
│   ├── app_text_style.dart      # Typography
│   ├── app_spacing.dart         # Spacing constants
│   ├── app_toast.dart           # Toast notifications
│   └── app_error_handler.dart   # Global error handling
└── ui/
    ├── views/                    # Screen widgets
    │   ├── dashboard_view.dart
    │   ├── appointment_view.dart
    │   ├── dual_signature_view.dart
    │   └── sign_in_view.dart
    └── widgets/                  # Reusable components
        ├── appointment_card.dart
        ├── timesheet_card.dart
        └── bottom_nav_bar.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- iOS development tools (for iOS builds)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Jossyboydgenius/mobo_app.git
   cd mobo_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   
   Create a `.env` file in the root directory (if not using default production API):
   ```
   BASE_URL_PROD=https://your-api-endpoint.com/api
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

### Firebase Setup

The app uses Firebase for push notifications. Follow these steps:

1. Add `google-services.json` (Android) to `android/app/`
2. Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
3. See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions

---

## 🔐 Authentication

### Login Flow

1. User enters credentials on Sign In screen
2. JWT token received from backend
3. Token stored securely using Flutter Secure Storage
4. "Remember Me" option for persistent authentication
5. Automatic token refresh on app restart

### API Authentication

All API calls include the JWT token in headers:
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

---

## ✍️ Dual Signature Feature

### Overview

The dual signature feature allows both the interpreter and client to electronically sign on the same screen to confirm visit completion. This creates a legally binding record of service delivery.

### How It Works

#### 1. **Access Methods**

**Option A: Clock Out Flow (Automatic)**
- When an interpreter clicks "Clock Out" on an active appointment
- App automatically navigates to the Dual Signature screen
- Both parties sign before clock out completes

**Option B: Quick Actions Menu (Manual)**
- Click the "Quick Actions" floating button on the Dashboard
- Select "Visit Signature Confirmation"
- Choose the appointment to sign

#### 2. **Signature Capture Process**

```
┌─────────────────────────────────────┐
│   Visit Signature Confirmation      │
├─────────────────────────────────────┤
│  Appointment Details:                │
│  • Client Name                       │
│  • Interpreter Name                  │
│  • Date & Time                       │
├─────────────────────────────────────┤
│  Interpreter Signature               │
│  ┌─────────────────────────────┐   │
│  │   [Signature Pad Area]      │   │
│  └─────────────────────────────┘   │
│                                      │
│  staff signature                    │
│  ┌─────────────────────────────┐   │
│  │   [Signature Pad Area]      │   │
│  └─────────────────────────────┘   │
│                                      │
│  [Submit Both Signatures] Button    │
└─────────────────────────────────────┘
```

#### 3. **Backend Integration**

**API Endpoint**: `PATCH /user-appointment/{appointmentId}/signature`

**Request Payload**:
```json
{
  "interpreterSignature": "data:image/png;base64,iVBORw0KGgo...",
  "clientSignature": "data:image/png;base64,iVBORw0KGgo..."
}
```

**Response**:
```json
{
  "status": "success",
  "message": "Signatures submitted successfully"
}
```

#### 4. **Local Backup**

Both signatures are automatically saved to device storage:
- **Android**: `/storage/emulated/0/Download/CareClink_Signatures/`
- **iOS**: App Documents Directory

File naming convention:
- `interpreter_signature_{appointmentId}_{timestamp}.png`
- `client_signature_{appointmentId}_{timestamp}.png`

### Implementation Details

**Dual Signature View**: `lib/ui/views/dual_signature_view.dart`
```dart
DualSignatureView(
  appointmentId: '12345',
  appointmentDetails: {
    'clientName': 'John Doe',
    'interpreterName': 'Jane Smith',
    'date': '2025-11-07',
    'timeIn': '09:00 AM',
    'timeOut': '11:00 AM',
  },
  isClockOutFlow: true, // true if from clock out, false if from menu
)
```

**Signature Service**: `lib/data/services/signature_service.dart`
```dart
// Upload both signatures
final response = await signatureService.uploadDualSignatures(
  appointmentId: appointmentId,
  interpreterSignatureBytes: interpreterBytes,
  clientSignatureBytes: clientBytes,
);
```

### Permission Handling

The app automatically requests storage permissions when saving signatures:

**Android Permissions** (in `AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

**iOS Permissions** (in `Info.plist`):
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>CareClink needs access to save signatures to your photo library</string>
```

---

## 📊 Visit Reports (Coming Soon)

Future functionality will include automatic PDF generation of visit reports containing:
- Appointment details (date, time, location)
- Client and interpreter information
- Service description and notes
- Both electronic signatures at the bottom
- Timestamp and unique reference number

---

## 🔧 Key Services

### SignatureService

Handles all signature-related operations:
- `uploadSignatureToAppointment()` - Single signature upload
- `uploadDualSignatures()` - Dual signature upload for visit confirmation
- `saveSignatureAsImage()` - Local storage with permission handling

### AppointmentService

Manages appointment lifecycle:
- `fetchAppointments()` - Get all appointments
- `clockIn()` - Start an appointment
- `uploadSignature()` - Attach signature to appointment

### TimesheetService

Tracks work hours:
- `clockIn()` - Start time tracking
- `clockOut()` - End time tracking with optional signature
- `getTimesheets()` - Retrieve timesheet history

### UserService

User management and authentication:
- `login()` - Authenticate user
- `getCurrentUser()` - Get authenticated user details
- `logout()` - Clear session

---

## 🎨 UI/UX Guidelines

### Color Scheme

```dart
AppColors.primary       // #0A3A6E (Primary brand color)
AppColors.secondary     // #4CAF50 (Success/Active states)
AppColors.grey1400      // Text primary
AppColors.grey1000      // Text secondary
AppColors.white         // Background
```

### Typography

```dart
AppTextStyle.semibold18  // Headers
AppTextStyle.medium16    // Sub-headers
AppTextStyle.regular14   // Body text
AppTextStyle.regular12   // Captions
```

### Spacing

```dart
AppSpacing.v8()   // 8px vertical
AppSpacing.v16()  // 16px vertical
AppSpacing.v24()  // 24px vertical
AppSpacing.h8()   // 8px horizontal
```

---

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/signature_service_test.dart

# With coverage
flutter test --coverage
```

### Test Signature Feature

Use the comprehensive signature test screen:
1. Navigate to "Signature Test Menu" (if in debug mode)
2. Test permission requests
3. Test signature capture and conversion
4. Test local saving
5. Test backend upload

---

## 📦 Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Then open in Xcode to archive and distribute.

---

## 🐛 Troubleshooting

### Common Issues

**Issue**: Firebase messaging not working
- **Solution**: See [FIREBASE_TROUBLESHOOTING.md](FIREBASE_TROUBLESHOOTING.md)

**Issue**: Signature permissions denied
- **Solution**: Check manifest permissions and request at runtime

**Issue**: Build errors with desugaring
- **Solution**: See [DESUGARING_FIX.md](DESUGARING_FIX.md)

**Issue**: Clock changes affecting authentication
- **Solution**: See [MANUAL_CLOCK_CHANGES.md](MANUAL_CLOCK_CHANGES.md)

---

## 📝 API Documentation

### Base URL
```
Production: https://multitenant-0iix.onrender.com/api
Development: http://localhost:8000/api
```

### Key Endpoints

#### Authentication
```
POST /api/auth/login
POST /api/auth/logout
GET /api/auth/me
```

#### Appointments
```
GET /api/appointments
GET /api/appointments/:id
POST /api/appointments
PATCH /api/appointments/:id
```

#### Signatures
```
PATCH /api/user-appointment/:id/signature
```
**Body**:
```json
{
  "signature": "data:image/png;base64,..."        // Single signature
  // OR
  "interpreterSignature": "data:image/png;base64,...",  // Dual signatures
  "clientSignature": "data:image/png;base64,..."
}
```

#### Timesheets
```
GET /api/timesheets
POST /api/timesheets/clock-in
PATCH /api/timesheets/:id/clock-out
```

---

## 🤝 Contributing

### Development Workflow

1. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the coding standards

3. Run tests and ensure they pass
   ```bash
   flutter test
   flutter analyze
   ```

4. Commit with conventional commit messages
   ```bash
   git commit -m "feat: add dual signature support"
   ```

5. Push and create a pull request

### Code Standards

- Follow Dart style guide
- Use meaningful variable/function names
- Add comments for complex logic
- Write tests for new features
- Keep widgets small and focused

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 📞 Support

For issues or questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the troubleshooting documentation

---

## 🗺️ Roadmap

### Current Version (1.0.0)
- ✅ User authentication
- ✅ Appointment management
- ✅ Time tracking
- ✅ Dual electronic signatures
- ✅ Push notifications

### Future Versions
- 📋 PDF visit report generation
- 📊 Analytics dashboard
- 🌐 Multi-language support
- 🔄 Offline sync improvements
- 📸 Photo attachments for visits

---

## 👥 Team

Developed by the CareClink Development Team

---

## 📚 Additional Documentation

- [Firebase Setup Guide](FIREBASE_SETUP.md)
- [Firebase Troubleshooting](FIREBASE_TROUBLESHOOTING.md)
- [Build Troubleshooting](BUILD_TROUBLESHOOTING.md)
- [Desugaring Fix Guide](DESUGARING_FIX.md)
- [Manual Clock Changes](MANUAL_CLOCK_CHANGES.md)
- [Server Setup Guide](SERVER_SETUP.md)

---

**Last Updated**: November 2025
**Version**: 1.0.0
