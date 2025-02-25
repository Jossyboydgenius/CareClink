import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/locator.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/user_service.dart';
import 'sign_in_event.dart';
import 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  SignInBloc() : super(const SignInState(status: SignInStatus.initial)) {
    on<SignInEmailChange>(_onEmailChanged);
    on<SignInPasswordChange>(_onPasswordChanged);
    on<SignInRememberMeChange>(_onRememberMeChanged);
    on<SignInUser>(_onSignInUser);
    on<SignInCheckSavedCredentials>(_onCheckSavedCredentials);
    on<SignInTogglePasswordVisibility>(_onTogglePasswordVisibility);
    _init();
  }

  final UserService _userService = locator<UserService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  Future<void> _init() async {
    try {
      final rememberMe = await _localStorageService.getRememberMe();
      if (rememberMe) {
        final savedEmail = await _localStorageService.getStorageValue(LocalStorageKeys.debugEmail);
        final savedPassword = await _localStorageService.getStorageValue(LocalStorageKeys.debugPassword);
        
        if (savedEmail != null && savedPassword != null) {
          add(SignInEmailChange(savedEmail));
          add(SignInPasswordChange(savedPassword));
          add(const SignInRememberMeChange(true));
        }
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  void _onEmailChanged(SignInEmailChange event, Emitter<SignInState> emit) {
    emit(state.copyWith(
      email: event.email,
    ));
  }

  void _onPasswordChanged(SignInPasswordChange event, Emitter<SignInState> emit) {
    emit(state.copyWith(
      password: event.password,
    ));
  }

  void _onTogglePasswordVisibility(SignInTogglePasswordVisibility event, Emitter<SignInState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onRememberMeChanged(SignInRememberMeChange event, Emitter<SignInState> emit) async {
    await _localStorageService.setRememberMe(event.rememberMe);
    if (!event.rememberMe) {
      await _localStorageService.clearAuthAll();
      await _localStorageService.saveStorageValue(LocalStorageKeys.rememberMe, 'false');
    }
    emit(state.copyWith(rememberMe: event.rememberMe));
  }

  Future<void> _onCheckSavedCredentials(SignInCheckSavedCredentials event, Emitter<SignInState> emit) async {
    final savedEmail = await _localStorageService.getStorageValue(LocalStorageKeys.debugEmail);
    final savedPassword = await _localStorageService.getStorageValue(LocalStorageKeys.debugPassword);
    final rememberMe = await _localStorageService.getRememberMe();
    
    if (savedEmail != null && savedPassword != null && rememberMe) {
      emit(state.copyWith(
        email: savedEmail,
        password: savedPassword,
        rememberMe: true,
      ));
    }
  }

  Future<void> _onSignInUser(SignInUser event, Emitter<SignInState> emit) async {
    emit(state.copyWith(status: SignInStatus.loading));

    try {
      final response = await _userService.login(
        email: state.email!,
        password: state.password!,
      );

      if (response.isSuccessful) {
        final token = response.data['token'];
        final user = response.data['user'];

        // Save auth credentials
        await _localStorageService.saveUserCredentials(
          token: token,
          userId: user['id'],
          email: user['email'],
          role: user['role'],
        );

        // Handle remember me
        if (state.rememberMe) {
          await _localStorageService.setRememberMe(true);
          await _localStorageService.saveStorageValue(LocalStorageKeys.debugEmail, state.email!);
          await _localStorageService.saveStorageValue(LocalStorageKeys.debugPassword, state.password!);
          await _localStorageService.saveStorageValue(LocalStorageKeys.rememberMe, 'true');
        } else {
          await _localStorageService.setRememberMe(false);
          await _localStorageService.clearAuthAll();
          await _localStorageService.saveStorageValue(LocalStorageKeys.rememberMe, 'false');
        }

        emit(state.copyWith(
          status: SignInStatus.success,
          data: response.data,
        ));
      } else {
        debugPrint('Error ${response.message}');
        emit(state.copyWith(
          status: SignInStatus.failure,
          errorMessage: response.message ?? 'Login failed',
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