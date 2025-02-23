import 'package:flutter/foundation.dart';
import '../../app/locator.dart';
import 'api/api.dart';
import 'api/api_response.dart';

class UserService {
  UserService._privateConstructor();

  static final UserService _instance = UserService._privateConstructor();

  factory UserService() {
    return _instance;
  }

  final Api _api = locator<Api>();

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
    return response;
  }
} 