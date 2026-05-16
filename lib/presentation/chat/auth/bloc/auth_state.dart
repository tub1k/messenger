part of 'auth_bloc.dart';

class AuthState {}

class AuthInitial extends AuthState {
  final String? errorText;

  AuthInitial({this.errorText});
}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String userId;

  AuthSuccess(this.userId);
}

