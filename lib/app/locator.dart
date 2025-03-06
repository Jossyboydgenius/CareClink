import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../data/services/api/api.dart';
import '../data/services/user_service.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/appointment_summary_service.dart';
import 'flavor_config.dart';

final locator = GetIt.instance;

Future<void> setupLocator(AppFlavorConfig config) async {
  await _registerExternalDependencies(config);
  _registerServices();
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
  if (!locator.isRegistered<AppointmentSummaryService>()) {
    locator.registerLazySingleton<AppointmentSummaryService>(() => AppointmentSummaryService());
  }
}

Future<void> _registerExternalDependencies(AppFlavorConfig config) async {
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
} 