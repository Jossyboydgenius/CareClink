import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/locator.dart';
import '../data/services/navigator_service.dart';
import '../app/routes/app_routes.dart';
import '../data/services/user_service.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/api/api_response.dart';
import '../shared/app_colors.dart';
import 'app_toast.dart';

class AppErrorHandler {
  static final UserService _userService = locator<UserService>();
  static final LocalStorageService _storageService =
      locator<LocalStorageService>();

  // Helper to check if the error is an interpreter-only restriction
  static bool _isInterpreterOnlyError(dynamic error) {
    if (error is ApiResponse && error.code == 403) {
      final message = error.message?.toLowerCase() ?? '';
      return message.contains('interpreter only') ||
          message.contains('interpreters only') ||
          message.contains('designed for interpreters');
    }

    // Check for type errors that are often related to interpreter-only features
    if (error is String) {
      final errorLower = error.toLowerCase();
      return (errorLower
              .contains("type 'string' is not a subtype of type 'map<string") &&
          (errorLower.contains("interpreter") ||
              errorLower.contains("clock") ||
              errorLower.contains("timesheet") ||
              errorLower.contains("appointment")));
    }

    return false;
  }

  // Helper method to show role access restriction dialog
  static void _showRoleAccessDialog(BuildContext context, String message) {
    // Show a dialog to inform the user about role access restrictions
    showDialog(
      context: context,
      barrierDismissible: false, // User must use a dialog button
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          // Prevent back button/gesture from dismissing, redirect to sign in
          onWillPop: () async {
            // Handle back button press by signing out and navigating to sign in
            await _userService.logout();
            NavigationService.pushNamedAndRemoveUntil(AppRoutes.signInView);
            return false; // Prevent dialog from closing naturally
          },
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0.r),
            ),
            title: Center(
              child: Text(
                'Access Restricted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.red,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.w,
                  color: AppColors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () async {
                      // Perform sign out and navigate to sign in
                      Navigator.of(dialogContext).pop();
                      await _userService.logout();
                      NavigationService.pushNamedAndRemoveUntil(
                          AppRoutes.signInView);
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Backward compatibility method to match the signature used in existing code
  static Future<bool> handleError(BuildContext context, dynamic error,
      {bool showToast = true}) async {
    debugPrint('Error handled: $error');

    String errorMessage = parseErrorMessage(error);

    // Check if error might be due to session expiration (no remember me)
    if (await _isSessionExpiredError(errorMessage)) {
      if (showToast) {
        AppToast.showError(
            context, "Your session has expired. Please sign in again.");
      }

      // Navigate to sign in
      await NavigationService.pushNamedAndRemoveUntil(AppRoutes.signInView);
      return true;
    }

    // Handle type errors which often indicate interpreter-only feature restrictions
    if (errorMessage
            .contains("type 'String' is not a subtype of type 'Map<String") ||
        errorMessage.contains("Failed to fetch timesheets") ||
        errorMessage.contains("Failed to clock in")) {
      // Don't show toast for role access errors, just show the dialog
      // Show the role access dialog to force sign out
      _showRoleAccessDialog(context,
          'You do not have permission to access this feature. Please sign in with the appropriate account.');
      return true;
    }

    // Check for interpreter-only API errors based on message content
    if (errorMessage.toLowerCase().contains("interpreter only") ||
        errorMessage.toLowerCase().contains("interpreters only") ||
        errorMessage.toLowerCase().contains("designed for interpreters") ||
        _isInterpreterOnlyError(error)) {
      // Don't show toast for role access errors, just show the dialog
      _showRoleAccessDialog(context,
          'You do not have permission to access this feature. Please sign in with the appropriate account.');
      return true;
    }

    // Check if user might need to sign out due to permission issues
    if (_checkForSessionIssues(error, context)) {
      return true; // Session issues already handled by _checkForSessionIssues
    }

    // For other errors, just show a toast
    if (showToast) {
      AppToast.showError(context, errorMessage);
    }

    return false;
  }

  // Check if error is due to session expiration (no remember me)
  static Future<bool> _isSessionExpiredError(String errorMessage) async {
    // If logout is in progress, don't treat auth errors as session expiration
    if (_userService.isLoggingOut) {
      debugPrint('Ignoring session expiration check during logout');
      return false;
    }

    // Check if the error is authorization related
    final bool isAuthError =
        errorMessage.toLowerCase().contains("unauthorized") ||
            errorMessage.toLowerCase().contains("not authorized") ||
            errorMessage.toLowerCase().contains("permission denied") ||
            errorMessage.toLowerCase().contains("token") ||
            errorMessage.contains("401");

    if (!isAuthError) {
      return false;
    }

    // Return true if remember me is not enabled and we have an auth error
    final isRememberMeOn = await _storageService.getRememberMe();
    return !isRememberMeOn;
  }

  // Main method to handle API response errors
  static void handleApiError(dynamic error, {BuildContext? context}) {
    // Early return if no context is provided - we can't show UI without context
    if (context == null) {
      debugPrint('No context provided to show error UI: $error');
      return;
    }

    // Parse the error message
    String errorMessage = parseErrorMessage(error);
    debugPrint('Handling error: $errorMessage');

    // Check for type errors which often indicate permission/interpreter issues
    if (errorMessage
            .contains("type 'String' is not a subtype of type 'Map<String") ||
        errorMessage.contains("Failed to fetch") ||
        errorMessage.contains("Failed to clock")) {
      // Don't show toast for role access errors, just show the dialog
      _showRoleAccessDialog(context,
          'You do not have permission to access this feature. Please sign in with the appropriate account.');
      return;
    }

    // Check for interpreter-only API errors
    if (_isInterpreterOnlyError(error)) {
      // Don't show toast for role access errors, just show the dialog
      _showRoleAccessDialog(context,
          'You do not have permission to access this feature. Please sign in with the appropriate account.');
      return;
    }

    // Check if error might be due to session expiration
    if (_checkForSessionIssues(error, context)) {
      return; // Session issues already handled by _checkForSessionIssues
    }

    // For standard errors, just show a toast
    AppToast.showError(context, errorMessage);
  }

  // Check if error is related to session expiration
  static bool _checkForSessionIssues(dynamic error, BuildContext context) {
    String errorMessage = parseErrorMessage(error);

    // Skip if this is an interpreter-only error (already handled elsewhere)
    if (errorMessage.toLowerCase().contains("interpreter") ||
        errorMessage.toLowerCase().contains("only") ||
        error is ApiResponse && error.code == 403) {
      return false;
    }

    // Check if we're in the middle of a logout flow
    // If logout is in progress, don't show authentication error toasts
    if (_userService.isLoggingOut) {
      debugPrint(
          'Auth error during logout detected and suppressed: $errorMessage');
      return true; // Return true to indicate we've handled it
    }

    // Check for general authorization issues
    if (errorMessage.toLowerCase().contains("unauthorized") ||
        errorMessage.toLowerCase().contains("permission denied") ||
        errorMessage.toLowerCase().contains("401") ||
        errorMessage.toLowerCase().contains("forbidden") ||
        errorMessage.toLowerCase().contains("token")) {
      // Show appropriate toast message
      AppToast.showError(
          context, "Your session has expired. Please sign in again.");

      // Sign out the user and redirect to login
      _userService.logout().then((_) {
        NavigationService.pushNamedAndRemoveUntil(AppRoutes.signInView);
      });

      return true;
    }

    return false;
  }

  // Helper to extract meaningful message from various error types
  static String parseErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }

    if (error is String) {
      return error;
    }

    if (error is ApiResponse) {
      if (error.message != null && error.message!.isNotEmpty) {
        // Check for role/permission-related messages
        if (error.message!.toLowerCase().contains('role') ||
            error.message!.toLowerCase().contains('permission')) {
          return 'You do not have permission to access this feature. Please sign in with the appropriate account.';
        }
        return error.message!;
      }
      return 'Error: ${error.code ?? "Unknown"}';
    }

    if (error is Map) {
      return error['message'] ?? error.toString();
    }

    // Extract message from error object if possible
    if (error.toString().contains('Exception:')) {
      return error.toString().split('Exception:').last.trim();
    }

    return error.toString();
  }
}
