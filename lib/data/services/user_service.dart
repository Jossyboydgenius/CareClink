import 'package:flutter/foundation.dart';
import '../../../app/locator.dart';
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

  Future<Map<String, dynamic>> updateUserDetails(
      Map<String, dynamic> user) async {
    debugPrint('Updating user details');
    final response = await _api.patchData(
      '/v1/user/update-user-details',
      user,
      hasHeader: true,
    );

    if (response.isSuccessful) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception('Failed to update user details: ${response.message}');
    }
  }

  Future<void> deleteUser(int userId) async {
    debugPrint('Deleting user');
    final response = await _api.deleteData(
      '/v1/user/delete-user?id=$userId',
      hasHeader: true,
    );

    if (!response.isSuccessful) {
      throw Exception('Failed to delete user: ${response.message}');
    }
  }
} 