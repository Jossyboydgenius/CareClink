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

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    debugPrint('Logging in user');
    final response = await _api.postData(
      '/user/login',
      {
        'email': email,
        'password': password,
      },
      hasHeader: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>;
      final token = data['token'];

      debugPrint('Saving user credentials - Token: $token');
      debugPrint('User data: ${user.toString()}');

      // Save auth credentials
      await _storage.saveUserCredentials(
        token: token,
        userId: user['id'],
        email: user['email'],
        role: user['role'],
        fullname: user['fullname'],
        profileImage: user['profileImage'],
      );

      // Update the API token immediately after login
      _api.updateToken(token);
      debugPrint('API token updated');
    }

    return response;
  }

  Future<bool> isUserLoggedIn() async {
    final credentials = await _storage.getUserCredentials();
    return credentials['token'] != null && credentials['token']!.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.clearAuthAll();
    _api.updateToken(null); // Clear the token on logout
  }

  Future<Map<String, String?>> getCurrentUser() async {
    final credentials = await _storage.getUserCredentials();
    debugPrint('Retrieved credentials: ${credentials.toString()}');
    
    // Update the API token when getting current user
    if (credentials['token'] != null) {
      _api.updateToken(credentials['token']!);
      debugPrint('Updated API token from stored credentials');
    }
    
    return credentials;
  }
} 