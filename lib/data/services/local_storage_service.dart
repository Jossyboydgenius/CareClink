import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/locator.dart';
import 'package:flutter/foundation.dart';

class LocalStorageKeys {
  static String refreshToken = 'refreshToken';
  static String accessToken = 'accessToken';
  static String expiresIn = 'expiresIn';
  static String debugName = 'debugName';
  static String debugEmail = 'debugEmail';
  static String debugPassword = 'debugPassword';
  static String timedOut = 'timedOut';
  static String rememberMe = 'rememberMe';
  static String userId = 'userId';
  static String userRole = 'userRole';
  static String userEmail = 'userEmail';
  static String userFullname = 'userFullname';
  static String userProfileImage = 'userProfileImage';
}

class LocalStorageService {
  final fSStorage = locator<FlutterSecureStorage>();

  Future<String?> getStorageValue(String key) async {
    String? value = await fSStorage.read(key: key);
    return value;
  }

  Future<void> saveStorageValue(String key, String value) async {
    return await fSStorage.write(key: key, value: value);
  }

  Future<bool> getRememberMe() async {
    final value = await getStorageValue(LocalStorageKeys.rememberMe);
    return value == 'true';
  }

  Future<void> setRememberMe(bool value) async {
    await saveStorageValue(LocalStorageKeys.rememberMe, value.toString());
  }

  Future<void> saveUserCredentials({
    required String token,
    required String userId,
    required String email,
    required String role,
    required String fullname,
    String? profileImage,
  }) async {
    debugPrint('Saving credentials to secure storage');
    await Future.wait([
      fSStorage.write(key: LocalStorageKeys.accessToken, value: token),
      fSStorage.write(key: LocalStorageKeys.userId, value: userId),
      fSStorage.write(key: LocalStorageKeys.userEmail, value: email),
      fSStorage.write(key: LocalStorageKeys.userRole, value: role),
      fSStorage.write(key: LocalStorageKeys.userFullname, value: fullname),
      if (profileImage != null)
        fSStorage.write(
            key: LocalStorageKeys.userProfileImage, value: profileImage),
    ]);
    debugPrint('Credentials saved successfully');
  }

  Future<Map<String, String?>> getUserCredentials() async {
    debugPrint('Retrieving credentials from secure storage');
    final credentials = await Future.wait([
      fSStorage.read(key: LocalStorageKeys.accessToken),
      fSStorage.read(key: LocalStorageKeys.userId),
      fSStorage.read(key: LocalStorageKeys.userEmail),
      fSStorage.read(key: LocalStorageKeys.userRole),
      fSStorage.read(key: LocalStorageKeys.userFullname),
      fSStorage.read(key: LocalStorageKeys.userProfileImage),
    ]);

    final result = {
      'token': credentials[0],
      'userId': credentials[1],
      'email': credentials[2],
      'role': credentials[3],
      'fullname': credentials[4],
      'profileImage': credentials[5],
    };
    debugPrint('Retrieved credentials: $result');
    return result;
  }

  Future<void> clearAuthAll() async {
    await fSStorage.delete(key: LocalStorageKeys.accessToken);
    await fSStorage.delete(key: LocalStorageKeys.refreshToken);
    await fSStorage.delete(key: LocalStorageKeys.expiresIn);
    await fSStorage.delete(key: LocalStorageKeys.debugName);
    await fSStorage.delete(key: LocalStorageKeys.debugEmail);
    await fSStorage.delete(key: LocalStorageKeys.debugPassword);
    await fSStorage.delete(key: LocalStorageKeys.timedOut);
    await fSStorage.delete(key: LocalStorageKeys.userId);
    await fSStorage.delete(key: LocalStorageKeys.userRole);
    await fSStorage.delete(key: LocalStorageKeys.userEmail);
    await fSStorage.delete(key: LocalStorageKeys.userFullname);
    await fSStorage.delete(key: LocalStorageKeys.userProfileImage);
    // Don't clear remember me preference when logging out
  }

  Future<void> clearAll() async => await fSStorage.deleteAll();

  // Check if auth token exists in storage
  Future<bool> hasAuthToken() async {
    final credentials = await getUserCredentials();
    return credentials['token'] != null && credentials['token']!.isNotEmpty;
  }

  // Clear just authentication credentials but keep other preferences
  Future<void> clearAuthCredentials() async {
    debugPrint('Clearing auth credentials from secure storage');
    await Future.wait([
      fSStorage.delete(key: LocalStorageKeys.accessToken),
      fSStorage.delete(key: LocalStorageKeys.refreshToken),
      fSStorage.delete(key: LocalStorageKeys.expiresIn),
      fSStorage.delete(key: LocalStorageKeys.userId),
      fSStorage.delete(key: LocalStorageKeys.userRole),
      fSStorage.delete(key: LocalStorageKeys.userEmail),
      fSStorage.delete(key: LocalStorageKeys.userFullname),
      fSStorage.delete(key: LocalStorageKeys.userProfileImage),
    ]);
    debugPrint('Auth credentials cleared while preserving other preferences');
  }
}
