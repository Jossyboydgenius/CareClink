import 'package:equatable/equatable.dart';

abstract class SignInEvent {
  const SignInEvent();
}

class SignInEmailChange extends SignInEvent {
  const SignInEmailChange(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

class SignInPasswordChange extends SignInEvent {
  const SignInPasswordChange(this.password);
  final String password;

  @override
  List<Object> get props => [password];
}

class SignInRememberMeChange extends SignInEvent {
  const SignInRememberMeChange(this.rememberMe);
  final bool rememberMe;

  @override
  List<Object> get props => [rememberMe];
}

class SignInTogglePasswordVisibility extends SignInEvent {
  const SignInTogglePasswordVisibility();
}

class SignInUser extends SignInEvent {
  const SignInUser();

  @override
  List<Object> get props => [];
}

class SignInCheckSavedCredentials extends SignInEvent {
  const SignInCheckSavedCredentials();

  @override
  List<Object> get props => [];
} 