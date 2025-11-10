import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';

class UserState {
  final String firstName;
  final String lastName;
  final String userId;
  final String email;
  final bool isLoading;
  final String activeKitchenId;
  final String role;
  final Uint8List? profilePictureFilePath;
  final String invitationCode;
  final bool entitlementIsActive;
  final List<MealTypeEntity> mealTypeEntity;
  final List<Map<String, dynamic>> doneSteps;
  final List<PantriesCommonEntity> userStorageAreas;
  const UserState({
    this.firstName = '',
    this.lastName = '',
    this.role = 'member',
    this.userId = '',
    this.profilePictureFilePath,
    this.email = '',
    this.isLoading = false,
    this.entitlementIsActive = false,
    this.activeKitchenId = '',
    this.invitationCode = '',
    this.mealTypeEntity = const [],
    this.doneSteps = const [],
    this.userStorageAreas = const [],
  });

  UserState copyWith({
    String? firstName,
    bool? entitlementIsActive,
    String? lastName,
    String? userId,
    String? activeKitchenId,
    String? role,
    String? email,
    Uint8List? profilePictureFilePath,
    bool? isLoading,
    String? invitationCode,
    List<MealTypeEntity>? mealTypeEntity,
    List<Map<String, dynamic>>? doneSteps,
    List<PantriesCommonEntity>? userStorageAreas,
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
      profilePictureFilePath:
          profilePictureFilePath ?? this.profilePictureFilePath,
      mealTypeEntity: mealTypeEntity ?? this.mealTypeEntity,
      doneSteps: doneSteps ?? this.doneSteps,
      userStorageAreas: userStorageAreas ?? this.userStorageAreas,
    );
  }
}
