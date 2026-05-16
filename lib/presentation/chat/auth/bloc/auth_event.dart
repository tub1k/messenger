part of 'auth_bloc.dart';

class AuthEvent {}

class AuthSignUpEmail extends AuthEvent {
  final String email;
  final String password;

  AuthSignUpEmail({required this.email, required this.password});
}

class AuthSignInEmail extends AuthEvent {
  final String email;
  final String password;

  AuthSignInEmail({required this.email, required this.password});
}

class AuthStarted extends AuthEvent {}