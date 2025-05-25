import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokalilmu_guru/model/loginregis_model.dart';
import 'package:lokalilmu_guru/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth Events
abstract class AuthEvent {}

class LoginTeacherEvent extends AuthEvent {
  final String emailOrPhone;
  final String password;

  LoginTeacherEvent({required this.emailOrPhone, required this.password});
}

class RegisterTeacherEvent extends AuthEvent {
  final Map<String, dynamic> registrationData;
  // final File ktpFile;

  RegisterTeacherEvent({
    required this.registrationData,
    // required this.ktpFile,
  });
}

class LogoutEvent extends AuthEvent {}

// Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final RegisterModel? user;
  final RegisterModel? profilGuru;
  final String token;

  AuthAuthenticated({
    this.user,
    this.profilGuru,
    required this.token,
  });
}

class AuthRegistrationSuccess extends AuthState {
  final RegisterModel? user;
  final RegisterModel? profilGuru;

  AuthRegistrationSuccess({
    this.user,
    this.profilGuru,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? errors;

  AuthError({
    required this.message,
    this.errors,
  });
}

// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginTeacherEvent>(_onLoginTeacher);
    on<RegisterTeacherEvent>(_onRegisterTeacher);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginTeacher(
    LoginTeacherEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await authRepository.loginTeacher(
        event.emailOrPhone,
        event.password,
      );

      if (response.success && response.token != null) {
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token!);
        
        emit(AuthAuthenticated(
          user: response.user,
          profilGuru: response.profilGuru,
          token: response.token!,
        ));
      } else {
        emit(AuthError(
          message: response.message ?? 'Login gagal',
          errors: response.errors,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterTeacher(
    RegisterTeacherEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final response = await authRepository.registerTeacher(
        event.registrationData,
        // event.ktpFile,
      );

      if (response.success) {
        // If token is provided in the response, save it
        if (response.token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', response.token!);
        }
        
        emit(AuthRegistrationSuccess(
          user: response.user,
          profilGuru: response.profilGuru,
        ));
      } else {
        emit(AuthError(
          message: response.message ?? 'Registrasi gagal',
          errors: response.errors,
        ));
      }
    } catch (e) {
      emit(AuthError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Clear token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    emit(AuthUnauthenticated());
  }
}
