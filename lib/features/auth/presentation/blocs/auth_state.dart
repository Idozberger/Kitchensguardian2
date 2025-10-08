part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthUserPasswordChanged extends AuthState {
  final String successMessage;
  AuthUserPasswordChanged(this.successMessage);
}

final class AuthSuccess extends AuthState {
  final String successMessage;
  AuthSuccess(this.successMessage);
}

final class AuthUserVerified extends AuthState {
  final String successMessage;
  AuthUserVerified(this.successMessage);
}

final class AuthForgotMailSent extends AuthState {
  final String successMessage;
  AuthForgotMailSent(this.successMessage);
}

final class AuthUserCreatedSuccess extends AuthState {
  final String successMessage;
  AuthUserCreatedSuccess(this.successMessage);
}

final class AuthUserEmailVerifiedSuccess extends AuthState {
  final String successMessage;
  AuthUserEmailVerifiedSuccess(this.successMessage);
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}
