import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/form_validator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_checkbox.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/app_images.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  bool get _isFormValid =>
      _emailError == null &&
      _passwordError == null &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  void _validateEmail() {
    setState(() {
      _emailError = FormValidators.validateEmail(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = FormValidators.validatePassword(_passwordController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppImages(
                  imagePath: AppImageData.careclinkLogo,
                  height: 60,
                  width: 60,
                ),
                AppSpacing.v32(),
                Text(
                  'Welcome back',
                  style: AppTextStyle.semibold24.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v8(),
                Text(
                  "We'll get you up and running in no time.",
                  style: AppTextStyle.regular14,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v32(),
                Text(
                  'Email Address',
                  style: AppTextStyle.medium14,
                ),
                AppSpacing.v8(),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: AppTextStyle.regular14.copyWith(
                      color: AppColors.grey300,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.grey400,
                      ),
                    ),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    _validateEmail();
                  },
                ),
                AppSpacing.v24(),
                Text(
                  'Password',
                  style: AppTextStyle.medium14,
                ),
                AppSpacing.v8(),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTextStyle.regular14.copyWith(
                      color: AppColors.grey300,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.grey400,
                      ),
                    ),
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.grey300,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  onChanged: (value) {
                    _validatePassword();
                  },
                ),
                AppSpacing.v16(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppCheckbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    AppSpacing.h8(),
                    Text(
                      'Remember me',
                      style: AppTextStyle.regular14.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v32(),
                AppButton(
                  text: 'Log in',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  enabled: _isFormValid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate login delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboardView);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
