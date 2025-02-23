import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/routes/app_routes.dart';
import 'app/themes.dart';
import 'data/services/navigator_service.dart';
import 'app/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (iPhone 12/13)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'CareClink',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: AppRoutes.signInView,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
