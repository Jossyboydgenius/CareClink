import 'package:flutter/material.dart';
import '../../app/locator.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/user_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_images.dart';
import '../../data/services/navigator_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _userService = locator<UserService>();

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final isLoggedIn = await _userService.isUserLoggedIn();
    if (isLoggedIn) {
      NavigationService.pushReplacementNamed(AppRoutes.dashboardView);
    } else {
      NavigationService.pushReplacementNamed(AppRoutes.signInView);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AppImages(
          imagePath: AppImageData.logo,
          height: 120,
          width: 120,
        ),
      ),
    );
  }
}