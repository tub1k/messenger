part of 'auth_bloc.dart';

class AuthEvent {}

class AuthSignUpEmail extends AuthEvent {
  final String email;
  final String password;
  final String username;

  AuthSignUpEmail({required this.email, required this.password, required this.username});
}

class AuthSignInEmail extends AuthEvent {
  final String email;
  final String password;
 
  AuthSignInEmail({required this.email, required this.password});
}

class AuthGoToUsernameScreen extends AuthEvent {}

class AuthStarted extends AuthEvent {}

class _AuthStatusChanged extends AuthEvent {
  final String? uid;
  _AuthStatusChanged(this.uid);
}