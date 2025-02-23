import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/services/api/api.dart';
import '../data/services/user_service.dart';
import 'flavor_config.dart';

final locator = GetIt.instance;

Future<void> setUpLocator() async {
  await dotenv.load(fileName: '.env');
  
  final config = AppFlavorConfig(
    name: dotenv.env['APP_NAME'] ?? 'development',
    apiBaseUrl: dotenv.env['API_BASE_URL'] ?? '',
    webUrl: dotenv.env['WEB_URL'] ?? '',
    mixpanelToken: dotenv.env['MIXPANEL_TOKEN'] ?? '',
  );
  
  locator.registerLazySingleton<AppFlavorConfig>(() => config);
  locator.registerLazySingleton<Api>(() => Api());
  locator.registerLazySingleton<UserService>(() => UserService());
} 