import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/locator.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/user_service.dart';
import '../../../shared/form_validator.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(const SignInState(status: SignInStatus.initial)) {
    on<SignInEmailChange>(_onEmailChanged);
    on<SignInPasswordChange>(_onPasswordChanged);
    on<SignInRememberMeChange>(_onRememberMeChanged);
    on<SignInUser>(_onSignInUser);
    on<SignInCheckSavedCredentials>(_onCheckSavedCredentials);
    _init();
  }

  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  Future<void> _init() async {
    final rememberMe = await _localStorageService.getRememberMe();
    if (rememberMe) {
      final credentials = await _localStorageService.getUserCredentials();
      if (credentials['email'] != null) {
        add(SignInEmailChange(credentials['email']!));
        emit(state.copyWith(rememberMe: true));
      }
    }
  }

  void _onEmailChanged(SignInEmailChange event, Emitter<SignInState> emit) {
    final email = event.email;
    final isEmailValid = FormValidators.validateEmail(email) == null;
    final isPasswordValid = FormValidators.validatePassword(state.password) == null;
    
    emit(state.copyWith(
      email: email,
      isFormValid: isEmailValid && isPasswordValid,
    ));
  }

  void _onPasswordChanged(SignInPasswordChange event, Emitter<SignInState> emit) {
    final password = event.password;
    final isPasswordValid = FormValidators.validatePassword(password) == null;
    final isEmailValid = FormValidators.validateEmail(state.email) == null;
    
    emit(state.copyWith(
      password: password,
      isFormValid: isEmailValid && isPasswordValid,
    ));
  }

  void _onRememberMeChanged(SignInRememberMeChange event, Emitter<SignInState> emit) async {
    await _localStorageService.setRememberMe(event.rememberMe);
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> _onCheckSavedCredentials(SignInCheckSavedCredentials event, Emitter<SignInState> emit) async {
    final credentials = await _localStorageService.getUserCredentials();
    if (credentials['email'] != null) {
      emit(state.copyWith(
        email: credentials['email'],
        rememberMe: true,
      ));
    }
  }

  Future<void> _onSignInUser(SignInUser event, Emitter<SignInState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: 'Please fix the errors in the form',
      ));
      return;
    }

    emit(state.copyWith(status: SignInStatus.loading));

    try {
      final response = await _userService.login(
        email: state.email!,
        password: state.password!,
      );

      if (response.isSuccessful) {
        final token = response.data['token'];
        final user = response.data['user'];

        await _localStorageService.saveUserCredentials(
          token: token,
          userId: user['id'],
          email: user['email'],
          role: user['role'],
        );

        if (state.rememberMe) {
          await _localStorageService.setRememberMe(true);
        } else {
          await _localStorageService.setRememberMe(false);
        }

        emit(state.copyWith(
          status: SignInStatus.success,
          data: response.data,
        ));
      } else {
        debugPrint('Error ${response.message}');
        emit(state.copyWith(
          status: SignInStatus.failure,
          errorMessage: response.message,
        ));
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
} 