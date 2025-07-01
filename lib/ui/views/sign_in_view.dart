import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../shared/form_validator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
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

  void _showRoleMismatchModal(BuildContext context, SignInState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: AppColors.red,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'Role Mismatch',
                style: AppTextStyle.semibold18.copyWith(
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The role you selected does not match your account role.',
                style: AppTextStyle.regular14.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Selected Role: ',
                          style: AppTextStyle.medium12.copyWith(
                            color: AppColors.grey300,
                          ),
                        ),
                        Text(
                          state.selectedRole == UserRole.staff
                              ? 'Staff'
                              : 'Interpreter',
                          style: AppTextStyle.semibold12.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          'Your Account Role: ',
                          style: AppTextStyle.medium12.copyWith(
                            color: AppColors.grey300,
                          ),
                        ),
                        Text(
                          state.actualRole?.toUpperCase() ?? 'Unknown',
                          style: AppTextStyle.semibold12.copyWith(
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Please select the correct role for your account and try again.',
                style: AppTextStyle.regular12.copyWith(
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
          actions: [
            AppButton(
              text: 'Try Again',
              onPressed: () {
                Navigator.of(context).pop();
                // Reset the sign-in state
                context.read<SignInBloc>().add(SignInRoleChange(
                      state.actualRole == 'staff'
                          ? UserRole.staff
                          : UserRole.interpreter,
                    ));
              },
              backgroundColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<SignInBloc, SignInState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == SignInStatus.success) {
                // AppToast.showSuccess(context, 'Sign in successful!');
                NavigationService.pushReplacementNamed(AppRoutes.dashboardView);
              } else if (state.status == SignInStatus.roleMismatch) {
                // Show role mismatch modal
                _showRoleMismatchModal(context, state);
              } else if (state.status == SignInStatus.failure) {
                AppToast.showError(
                    context, state.errorMessage ?? 'Something went wrong');
              }
            },
            child: BlocBuilder<SignInBloc, SignInState>(
              builder: (context, state) {
                // Update controllers when state changes
                if (state.email != null &&
                    _emailController.text != state.email) {
                  _emailController.text = state.email!;
                }
                if (state.password != null &&
                    _passwordController.text != state.password) {
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
                        AppInput(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: FormValidators.validateEmail,
                          onChanged: (value) {
                            context
                                .read<SignInBloc>()
                                .add(SignInEmailChange(value));
                          },
                        ),
                        AppSpacing.v24(),
                        AppInput(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          obscureText: state.obscurePassword,
                          validator: FormValidators.validatePassword,
                          onChanged: (value) {
                            context
                                .read<SignInBloc>()
                                .add(SignInPasswordChange(value));
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.grey300,
                              size: 20.w,
                            ),
                            onPressed: () {
                              context
                                  .read<SignInBloc>()
                                  .add(const SignInTogglePasswordVisibility());
                            },
                          ),
                        ),
                        AppSpacing.v24(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Login as',
                              style: AppTextStyle.medium14,
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey400),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserRole>(
                                  isExpanded: true,
                                  value: state.selectedRole,
                                  items: [
                                    DropdownMenuItem(
                                      value: UserRole.interpreter,
                                      child: Text(
                                        'Interpreter',
                                        style: AppTextStyle.regular14,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: UserRole.staff,
                                      child: Text(
                                        'Staff',
                                        style: AppTextStyle.regular14,
                                      ),
                                    ),
                                  ],
                                  onChanged: (UserRole? value) {
                                    if (value != null) {
                                      context
                                          .read<SignInBloc>()
                                          .add(SignInRoleChange(value));
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
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
                              context
                                  .read<SignInBloc>()
                                  .add(const SignInUser());
                            }
                          },
                          isLoading: state.status == SignInStatus.loading,
                          enabled:
                              state.email != null && state.password != null,
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
