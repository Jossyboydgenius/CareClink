abstract class SignInEvent {
  const SignInEvent();
}

class SignInEmailChange extends SignInEvent {
  const SignInEmailChange(this.email);
  final String email;
}

class SignInPasswordChange extends SignInEvent {
  const SignInPasswordChange(this.password);
  final String password;
}

class SignInRememberMeChange extends SignInEvent {
  const SignInRememberMeChange(this.rememberMe);
  final bool rememberMe;
}

class SignInTogglePasswordVisibility extends SignInEvent {
  const SignInTogglePasswordVisibility();
}

class SignInUser extends SignInEvent {
  const SignInUser();
}

class SignInCheckSavedCredentials extends SignInEvent {
  const SignInCheckSavedCredentials();
} 