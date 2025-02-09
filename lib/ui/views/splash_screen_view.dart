import 'package:flutter/material.dart';
import 'package:mobo_app/ui/views/sign_in_view.dart';
import 'package:mobo_app/shared/app_images.dart';
import 'package:mobo_app/shared/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInView()),
      );
    });
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