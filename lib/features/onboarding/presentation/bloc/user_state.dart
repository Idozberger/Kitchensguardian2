part of 'user_bloc.dart';

sealed class UserState {
  const UserState();
}

final class UserInitial extends UserState {}

final class TokenExpired extends UserState {}

final class NoInternet extends UserState {}

final class UserLoading extends UserState {}

final class UserSuccess extends UserState {}

final class UserGetStarted extends UserState {}

final class UserOnBoarded extends UserState {}
