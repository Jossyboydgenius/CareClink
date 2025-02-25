import 'package:equatable/equatable.dart';
import '../../../shared/form_validator.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState {
  const SignInState({
    this.status = SignInStatus.initial,
    this.email,
    this.password,
    this.emailError,
    this.passwordError,
    this.rememberMe = false,
    this.obscurePassword = true,
    this.isFormValid = false,
    this.errorMessage,
    this.data,
  });

  final SignInStatus status;
  final String? email;
  final String? password;
  final String? emailError;
  final String? passwordError;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isFormValid;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  bool get isButtonEnabled =>
      isFormValid && status != SignInStatus.loading && email != null && password != null;

  @override
  List<Object?> get props => [
        email,
        status,
        password,
        isFormValid,
        errorMessage,
        rememberMe,
      ];

  SignInState copyWith({
    SignInStatus? status,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool? rememberMe,
    bool? obscurePassword,
    bool? isFormValid,
    String? errorMessage,
    Map<String, dynamic>? data,
  }) {
    return SignInState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError ?? this.emailError,
      passwordError: passwordError ?? this.passwordError,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isFormValid: isFormValid ?? this.isFormValid,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
    );
  }
} 