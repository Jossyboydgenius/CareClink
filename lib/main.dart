import 'package:flutter/material.dart';
import 'ui/views/splash_screen.dart';
import 'app/themes.dart';
import 'shared/app_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logo Company',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        AppDimension.init(context);
        return child!;
      },
      home: const SplashScreen(),
    );
  }
}
