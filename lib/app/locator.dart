import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../data/services/api/api.dart';
import '../data/services/user_service.dart';
import '../data/services/local_storage_service.dart';
import 'flavor_config.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Using dart-define values.');
  }

  final config = _initConfig();
  await _registerExternalDependencies(config);
  _registerServices();
}

AppFlavorConfig _initConfig() {
  // Try to get from dart-define first, then fallback to .env
  final appName = const String.fromEnvironment('APP_NAME').isNotEmpty
      ? const String.fromEnvironment('APP_NAME')
      : dotenv.env['APP_NAME'] ?? 'CareClink';

  final apiBaseUrl = const String.fromEnvironment('API_BASE_URL').isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : dotenv.env['API_BASE_URL'];

  final webUrl = const String.fromEnvironment('WEB_URL').isNotEmpty
      ? const String.fromEnvironment('WEB_URL')
      : dotenv.env['WEB_URL'] ?? '';

  final mixpanelToken = const String.fromEnvironment('MIXPANEL_TOKEN').isNotEmpty
      ? const String.fromEnvironment('MIXPANEL_TOKEN')
      : dotenv.env['MIXPANEL_TOKEN'] ?? '';

  if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
    throw AssertionError('API_BASE_URL must be provided either through dart-define or .env file');
  }

  return AppFlavorConfig(
    name: appName,
    apiBaseUrl: apiBaseUrl,
    webUrl: webUrl,
    mixpanelToken: mixpanelToken,
  );
}

void _registerServices() {
  if (!locator.isRegistered<Api>()) {
    locator.registerLazySingleton<Api>(() => Api());
  }
  if (!locator.isRegistered<UserService>()) {
    locator.registerLazySingleton<UserService>(() => UserService());
  }
  if (!locator.isRegistered<LocalStorageService>()) {
    locator.registerLazySingleton<LocalStorageService>(() => LocalStorageService());
  }
}

Future<void> _registerExternalDependencies(AppFlavorConfig config) async {
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
} 