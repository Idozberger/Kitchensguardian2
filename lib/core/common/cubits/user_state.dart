import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String firstName;
  final String lastName;
  final String userId;
  final String email;
  final bool isLoading;
  final String activeKitchenId;

  const UserState({
    this.firstName = '',
    this.lastName = '',
    this.userId = '',
    this.email = '',
    this.isLoading = false,
    this.activeKitchenId = "",
  });

  UserState copyWith({
    String? firstName,
    String? lastName,
    String? userId,
    String? activeKitchenId,
    String? email,
    bool? isLoading,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      userId: userId ?? this.userId,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      activeKitchenId: activeKitchenId ?? this.activeKitchenId,
    );
  }

  @override
  List<Object> get props => [
    firstName,
    lastName,
    userId,
    email,
    isLoading,
    activeKitchenId,
  ];
}
