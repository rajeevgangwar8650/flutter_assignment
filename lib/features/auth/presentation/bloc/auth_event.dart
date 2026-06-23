import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthSessionRestoreRequested extends AuthEvent {
  const AuthSessionRestoreRequested();
}

class AuthSignInSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
