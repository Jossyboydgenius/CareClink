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
    on<SignInUser>(_onSignInUser);
  }

  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

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

  void _saveAuthInfo(String token) {
    _localStorageService.saveStorageValue(LocalStorageKeys.accessToken, token);
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
        _saveAuthInfo(token);

        _localStorageService.saveStorageValue(
          LocalStorageKeys.debugEmail,
          state.email!,
        );
        _localStorageService.saveStorageValue(
          LocalStorageKeys.debugPassword,
          state.password!,
        );

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