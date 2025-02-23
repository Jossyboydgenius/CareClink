import 'package:equatable/equatable.dart';
import '../../../shared/form_validator.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final String? email;
  final String? password;
  final String? errorMessage;
  final SignInStatus status;
  final dynamic data;
  final bool isFormValid;

  const SignInState({
    required this.status,
    this.email,
    this.password,
    this.errorMessage,
    this.data,
    this.isFormValid = false,
  });

  bool get isButtonEnabled =>
      isFormValid && status != SignInStatus.loading && email != null && password != null;

  String? get emailError => email != null ? FormValidators.validateEmail(email) : null;
  String? get passwordError => password != null ? FormValidators.validatePassword(password) : null;

  @override
  List<Object?> get props => [
        email,
        status,
        password,
        isFormValid,
        errorMessage,
      ];

  SignInState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    SignInStatus? status,
    dynamic data,
    bool? isFormValid,
  }) {
    return SignInState(
      email: email ?? this.email,
      status: status ?? this.status,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
} 