import 'package:equatable/equatable.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
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

class SignInUser extends SignInEvent {
  const SignInUser();

  @override
  List<Object> get props => [];
} 