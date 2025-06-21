import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import 'api/api.dart';
import 'api/api_response.dart';
import 'local_storage_service.dart';

class UserService {
  UserService._privateConstructor();

  static final UserService _instance = UserService._privateConstructor();

  factory UserService() {
    return _instance;
  }

  final Api _api = locator<Api>();
  final LocalStorageService _storage = locator<LocalStorageService>();

  // Cache the user data to prevent multiple fetches
  Map<String, String?>? _cachedUserData;
  bool _isLoadingUserData = false;
  bool _isLoggingOut = false; // Add this flag to track logout state

  // Add a getter to check if logout is in progress
  bool get isLoggingOut => _isLoggingOut;

  Future<ApiResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
    String role =
        'interpreter', // Default to interpreter for backward compatibility
  }) async {
    debugPrint('Logging in user with Remember Me: $rememberMe, Role: $role');

    // Using the same login endpoint for both roles
    const String loginEndpoint = '/user/login';

    final response = await _api.postData(
      loginEndpoint,
      {
        'email': email,
        'password': password,
        // Role is not sent in request body, but stored locally after login
      },
      hasHeader: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      final token = data['token'];

      // Log the user role for debugging
      debugPrint('User role from login response: ${user['role']}');

      debugPrint('Login successful - Token: $token');
      debugPrint('User data: ${user.toString()}');

      // ALWAYS update the API token immediately in memory after login
      // regardless of remember me setting. This is crucial for the app to work
      // during the current session even if remember me is not checked
      _api.updateToken(token);
      debugPrint('API token updated in memory');

      // ALWAYS cache the user data in memory regardless of remember me setting
      // This ensures the user can use the app during the current session
      _cachedUserData = {
        'token': token,
        'userId': user['id'],
        'email': user['email'],
        'role': user['role'],
        'fullname': user['fullname'],
        'profileImage': user['profileImage'],
      };
      debugPrint('User data cached in memory');

      // Handle remember me preference
      if (rememberMe) {
        // If remember me is checked, save credentials to secure storage
        debugPrint(
            'Remember Me is checked, saving credentials to secure storage');
        await _storage.saveUserCredentials(
          token: token,
          userId: user['id'],
          email: user['email'],
          role: user['role'],
          fullname: user['fullname'],
          profileImage: user['profileImage'],
        );

        // Save the remember me preference
        await _storage.setRememberMe(true);
        debugPrint('Remember Me preference saved as true');
      } else {
        // If remember me is not checked, make sure we clear any stored credentials
        // but keep the in-memory token active for this session
        debugPrint('Remember Me not checked, using in-memory credentials only');

        // Update remember me preference
        await _storage.setRememberMe(false);
        debugPrint('Remember Me preference saved as false');

        // Clear stored credentials to avoid using them in future app launches
        await _storage.clearAuthCredentials();
        debugPrint(
            'Cleared any previously stored credentials from secure storage');

        // Double check that in-memory token is still set (should be redundant)
        // Note: We can't directly access the private _token field, but we can check if
        // updateToken succeeded by checking our cached data
        if (_cachedUserData == null ||
            _cachedUserData!['token'] == null ||
            _cachedUserData!['token']!.isEmpty) {
          debugPrint('WARNING: In-memory token may not be set, resetting it');
          _api.updateToken(token);
        }
      }
    }

    return response;
  }

  Future<bool> isUserLoggedIn() async {
    final credentials = await _storage.getUserCredentials();
    return credentials['token'] != null && credentials['token']!.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      // Set the logging out flag to true
      _isLoggingOut = true;
      debugPrint('Logging out user...');

      // Clear the in-memory token first to prevent further API calls
      _api.updateToken(null);
      debugPrint('In-memory token cleared');

      // Clear the cached user data
      _cachedUserData = null;
      debugPrint('In-memory cached user data cleared');

      // Clear all stored credentials
      await _storage.clearAuthAll();
      debugPrint('Stored credentials cleared from secure storage');

      debugPrint('Logout completed successfully');
    } catch (e) {
      // Log the error but don't throw it to prevent UI errors during logout
      debugPrint('Error during logout: $e');
    } finally {
      // Reset the logging out flag whether logout succeeded or failed
      _isLoggingOut = false;
    }
  }

  Future<Map<String, String?>> getCurrentUser() async {
    // If we're already loading user data, wait for it to finish to avoid race conditions
    if (_isLoadingUserData) {
      // Wait a bit and check again to avoid infinite loops
      await Future.delayed(const Duration(milliseconds: 100));
      return getCurrentUser();
    }

    // If we have cached data, return it immediately
    if (_cachedUserData != null) {
      return _cachedUserData!;
    }

    _isLoadingUserData = true;

    try {
      final credentials = await _storage.getUserCredentials();
      debugPrint('Retrieved credentials: ${credentials.toString()}');

      // Update the API token when getting current user
      if (credentials['token'] != null) {
        _api.updateToken(credentials['token']!);
        debugPrint('Updated API token from stored credentials');
      }

      // Cache the user data
      _cachedUserData = Map<String, String?>.from(credentials);
      return _cachedUserData!;
    } finally {
      _isLoadingUserData = false;
    }
  }

  // Force refresh user data from storage
  Future<Map<String, String?>> refreshCurrentUser() async {
    _cachedUserData = null;
    return getCurrentUser();
  }

  // Check if we have credentials cached in memory
  bool hasCachedUserData() {
    return _cachedUserData != null &&
        _cachedUserData!['token'] != null &&
        _cachedUserData!['token']!.isNotEmpty;
  }

  // Clear just auth credentials without affecting other data
  Future<void> clearAuthCredentials() async {
    try {
      await _storage.clearAuthCredentials();
      debugPrint('Auth credentials cleared from storage');
    } catch (e) {
      debugPrint('Error clearing auth credentials: $e');
    }
  }
}
