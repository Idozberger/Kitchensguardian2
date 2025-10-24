import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String firstName;
  final String lastName;
  final String userId;
  final String email;
  final bool isLoading;
  final String activeKitchenId;
  final String role;
  final String invitationCode;
  final bool entitlementIsActive;
  const UserState({
    this.firstName = '',
    this.lastName = '',
    this.role = 'member',
    this.userId = '',
    this.email = '',
    this.isLoading = false,
    this.entitlementIsActive = false,
    this.activeKitchenId = "",
    this.invitationCode = "",
  });

  UserState copyWith({
    String? firstName,
    bool? entitlementIsActive,
    String? lastName,
    String? userId,
    String? activeKitchenId,
    String? role,
    String? email,
    bool? isLoading,
    String? invitationCode,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      entitlementIsActive: entitlementIsActive ?? this.entitlementIsActive,
      role: role ?? this.role,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      activeKitchenId: activeKitchenId ?? this.activeKitchenId,
      invitationCode: invitationCode ?? this.invitationCode,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object> get props => [
    firstName,
    entitlementIsActive,
    lastName,
    userId,
    email,
    isLoading,
    activeKitchenId,
    invitationCode,
  ];
}
