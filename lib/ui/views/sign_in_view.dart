import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/form_validator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_checkbox.dart';
import '../../shared/app_images.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';
import 'sign_in_bloc/sign_in_bloc.dart';
import 'sign_in_bloc/sign_in_event.dart';
import 'sign_in_bloc/sign_in_state.dart';
import '../../shared/app_toast.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SignInBloc>().add(const SignInCheckSavedCredentials());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<SignInBloc, SignInState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == SignInStatus.success) {
                // AppToast.showSuccess(context, 'Sign in successful!');
                NavigationService.pushReplacementNamed(AppRoutes.dashboardView);
              } else if (state.status == SignInStatus.failure) {
                AppToast.showError(context, state.errorMessage ?? 'Something went wrong');
              }
            },
            child: BlocBuilder<SignInBloc, SignInState>(
              builder: (context, state) {
                // Update controllers when state changes
                if (state.email != null && _emailController.text != state.email) {
                  _emailController.text = state.email!;
                }
                if (state.password != null && _passwordController.text != state.password) {
                  _passwordController.text = state.password!;
                }

                return SingleChildScrollView(
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
                        TextFormField(
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
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.validateEmail,
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
                        TextFormField(
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
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.grey300,
                              ),
                              onPressed: () {
                                context.read<SignInBloc>().add(
                                    const SignInTogglePasswordVisibility());
                              },
                            ),
                          ),
                          obscureText: state.obscurePassword,
                          validator: FormValidators.validatePassword,
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
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInBloc>().add(const SignInUser());
                            }
                          },
                          isLoading: state.status == SignInStatus.loading,
                          enabled: state.email != null && state.password != null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
