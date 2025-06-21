# Build Troubleshooting Guide

This document outlines the solutions to the build issues encountered in the CareClink app.

## Issue 1: fluttertoast Compilation Errors

The `fluttertoast` package version 8.2.8 was causing Kotlin compilation errors:

```
e: Unresolved reference: Registrar
e: Unresolved reference: FlutterMain
```

### Solution
We've temporarily commented out the `fluttertoast` package in `pubspec.yaml`. If you need toast notifications, consider using alternatives like:

1. `another_fluttertoast`
2. `oktoast`
3. `flash` 
4. Custom implementation using the Flutter Overlay API

## Issue 2: flutter_local_notifications Compilation Error

The `flutter_local_notifications` package was causing Java compilation errors due to ambiguous references:

```
error: reference to bigLargeIcon is ambiguous
```

### Solution
We've temporarily commented out the `flutter_local_notifications` package in `pubspec.yaml`. If you need to implement notifications, consider:

1. Using only Firebase Cloud Messaging (FCM) for notifications
2. Implementing a custom solution
3. Using alternative notification packages

## Issue 3: Android Gradle Plugin Warning

Warning about Android Gradle Plugin version being deprecated:

```
Warning: Flutter support for your project's Android Gradle Plugin version (Android Gradle Plugin version 8.2.1) will soon be dropped
```

### Solution
We've verified that the project is using AGP 8.3.0 in:
- `android/settings.gradle` - Plugin version is set to 8.3.0

## Build Success

After commenting out the problematic packages and updating the Firebase dependencies to compatible versions, the build succeeds. The APK was successfully generated at:

```
build/app/outputs/flutter-apk/app-release.apk
```

## Additional Recommendations

1. Consider upgrading to the latest compatible versions of all packages using:
   ```
   flutter pub upgrade --major-versions
   ```

2. For network-related dependency resolution issues:
   - We've added fallback maven repositories in `android/build.gradle`
   - Consider using a reliable network connection or a VPN if maven.google.com is not accessible

3. For building the app with warnings:
   ```
   flutter build apk --android-skip-build-dependency-validation
   ```
