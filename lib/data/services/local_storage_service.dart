import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/locator.dart';

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
  }) async {
    await saveStorageValue(LocalStorageKeys.accessToken, token);
    await saveStorageValue(LocalStorageKeys.userId, userId);
    await saveStorageValue(LocalStorageKeys.userEmail, email);
    await saveStorageValue(LocalStorageKeys.userRole, role);
  }

  Future<Map<String, String?>> getUserCredentials() async {
    return {
      'token': await getStorageValue(LocalStorageKeys.accessToken),
      'userId': await getStorageValue(LocalStorageKeys.userId),
      'email': await getStorageValue(LocalStorageKeys.userEmail),
      'role': await getStorageValue(LocalStorageKeys.userRole),
    };
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
    // Don't clear remember me preference when logging out
  }

  Future<void> clearAll() async => await fSStorage.deleteAll();
} 