part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  AuthSignUp({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });
}

final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;
  AuthSignIn({required this.email, required this.password});
}

final class AuthSendPasswordResetEmail extends AuthEvent {
  final String email;

  AuthSendPasswordResetEmail({required this.email});
}

final class AuthSetUserNewPassword extends AuthEvent {
  final String email;
  final String newPassword;

  AuthSetUserNewPassword({required this.email, required this.newPassword});
}

final class AuthVerifyEmail extends AuthEvent {
  final String code;

  AuthVerifyEmail({required this.code});
}
