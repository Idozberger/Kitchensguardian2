part of 'user_bloc.dart';

sealed class UserEvent {}

class GetCurrentUser extends UserEvent {}

class GetStartedEvent extends UserEvent {}

class IsUserOnboarded extends UserEvent {}
