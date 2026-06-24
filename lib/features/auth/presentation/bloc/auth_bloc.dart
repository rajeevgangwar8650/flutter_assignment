import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final LogoutUseCase logoutUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
  }) : super(const AuthInitial()) {
    on<AuthSessionRestoreRequested>(_onSessionRestoreRequested);
    on<AuthSignInSubmitted>(_onSignInSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSessionRestoreRequested(AuthSessionRestoreRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await restoreSessionUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(
        user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
      ),
    );
  }

  Future<void> _onSignInSubmitted(AuthSignInSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signInUseCase(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
