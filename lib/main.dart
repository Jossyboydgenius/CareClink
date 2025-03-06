import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/routes/app_routes.dart';
import 'app/themes.dart';
import 'data/services/navigator_service.dart';
import 'app/locator.dart';
import 'app/flavor_config.dart';
import 'ui/views/sign_in_bloc/sign_in_bloc.dart';
import 'shared/app_sizer.dart';
import 'shared/connection_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await setupLocator(AppFlavorConfig(
    name: 'CareClink',
    apiBaseUrl: dotenv.env['BASE_URL_PROD']!,
    webUrl: dotenv.env['WEB_URL_PROD']!,
    mixpanelToken: dotenv.env['MIXPANEL_TOKEN_PROD']!,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppDimension.init(context);
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SignInBloc()),
          ],
          child: MaterialApp(
            title: 'CareClink',
            navigatorKey: NavigationService.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.routes,
            builder: (context, child) {
              ScreenUtil.init(context);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: ConnectionWidget(
                  dismissOfflineBanner: false,
                  builder: (context, isOnline) {
                    return child!;
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
