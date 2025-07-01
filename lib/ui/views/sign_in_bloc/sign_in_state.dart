enum SignInStatus { initial, loading, success, failure, roleMismatch }

enum UserRole { interpreter, staff }

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
    this.selectedRole = UserRole.interpreter,
    this.actualRole,
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
  final UserRole selectedRole;
  final String? actualRole; // The actual role from the server

  bool get isButtonEnabled =>
      isFormValid &&
      status != SignInStatus.loading &&
      email != null &&
      password != null;

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
    UserRole? selectedRole,
    String? actualRole,
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
      selectedRole: selectedRole ?? this.selectedRole,
      actualRole: actualRole ?? this.actualRole,
    );
  }
}
