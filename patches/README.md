# Package Patches

This directory contains patches for Flutter packages that are causing build issues.

## fluttertoast
The patch fixes Kotlin compilation errors related to deprecated Flutter APIs (Registrar and FlutterMain).

## flutter_local_notifications
The patch disables lint tasks that are failing due to network connectivity issues when downloading Robolectric dependencies.
