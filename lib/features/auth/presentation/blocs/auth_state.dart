part of 'auth_bloc.dart';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthEmailVerificationCodeSent extends AuthState {
  final String successMessage;
  AuthEmailVerificationCodeSent(this.successMessage);
}

final class FetchingUserDetails extends AuthState {}

final class FetchedUserDetails extends AuthState {}

final class ErrorFetchingUserDetails extends AuthState {
  final String errorMessage;
  ErrorFetchingUserDetails(this.errorMessage);
}

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

final class CodeResendLoading extends AuthState {}

final class ResendEmailVerficationCode extends AuthState {
  final String message;
  const ResendEmailVerficationCode(this.message);
}

final class GoogleAuthLoading extends AuthState {}

final class GoogleAuthsignUpLoading extends AuthState {}

final class AppleSignInLoading extends AuthState {}

final class AppleSignUpLoading extends AuthState {}
