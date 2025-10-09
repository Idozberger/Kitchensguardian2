import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final bool isLoading;

  const UserState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.isLoading = false,
  });

  UserState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    bool? isLoading,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [firstName, lastName, email, isLoading];
}
