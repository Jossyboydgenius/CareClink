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

    // If login is successful, store the credentials
    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      await _storage.saveUserCredentials(
        token: data['token'],
        userId: data['userId'],
        email: data['email'],
        role: data['role'],
      );
    }

    return response;
  }

  Future<bool> isUserLoggedIn() async {
    final credentials = await _storage.getUserCredentials();
    return credentials['token'] != null && credentials['token']!.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.clearAuthAll();
  }
} 