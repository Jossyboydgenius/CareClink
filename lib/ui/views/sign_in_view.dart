import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/form_validator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_checkbox.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/app_images.dart';
import '../../data/services/user_service.dart';
import '../../app/locator.dart';
import 'sign_in_bloc/sign_in_bloc.dart';
import 'sign_in_bloc/sign_in_event.dart';
import 'sign_in_bloc/sign_in_state.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(),
      child: const SignInContent(),
    );
  }
}

class SignInContent extends StatefulWidget {
  const SignInContent({super.key});

  @override
  State<SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = locator<UserService>();
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to state changes to update controllers
    Future.delayed(Duration.zero, () {
      final state = context.read<SignInBloc>().state;
      if (state.email != null) {
        _emailController.text = state.email!;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state.status == SignInStatus.failure) {
          _showErrorSnackBar(state.errorMessage ?? 'Login failed');
        } else if (state.status == SignInStatus.success) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.dashboardView);
        }

        // Update email controller when state changes
        if (state.email != null && _emailController.text != state.email) {
          _emailController.text = state.email!;
        }
      },
      builder: (context, state) {
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
                        errorText: state.emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        context.read<SignInBloc>().add(SignInEmailChange(value));
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
                        errorText: state.passwordError,
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
                        context.read<SignInBloc>().add(SignInPasswordChange(value));
                      },
                    ),
                    AppSpacing.v16(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppCheckbox(
                          value: state.rememberMe,
                          onChanged: (value) {
                            context.read<SignInBloc>().add(
                                SignInRememberMeChange(value ?? false));
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
                      onPressed: () {
                        if (state.isFormValid) {
                          context.read<SignInBloc>().add(const SignInUser());
                        }
                      },
                      isLoading: state.status == SignInStatus.loading,
                      enabled: state.isButtonEnabled,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
