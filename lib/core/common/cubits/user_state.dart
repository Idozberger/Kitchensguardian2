import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';

class UserState {
  final String firstName;
  final String lastName;
  final String userId;
  final String email;
  final bool isLoading;
  final String activeKitchenId;
  final String kitchenName;
  final String role;
  final Uint8List? profilePictureFilePath;
  final String invitationCode;
  final bool entitlementIsActive;
  final List<RecipeEntity> recipeEntity;
  final List<List<Map<String, dynamic>>> doneSteps;
  final List<PantriesCommonEntity> userStorageAreas;
  final UserModel? userModel;
  const UserState({
    this.kitchenName = "",
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
    this.recipeEntity = const [],
    this.doneSteps = const [],
    this.userStorageAreas = const [],
    this.userModel,
  });

  UserState copyWith({
    String? firstName,
    String? kitchenName,
    bool? entitlementIsActive,
    String? lastName,
    String? userId,
    String? activeKitchenId,
    String? role,
    String? email,
    Uint8List? profilePictureFilePath,
    bool? isLoading,
    String? invitationCode,
    List<RecipeEntity>? recipeEntity,
    List<List<Map<String, dynamic>>>? doneSteps,
    List<PantriesCommonEntity>? userStorageAreas,
    UserModel? userModel,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      entitlementIsActive: entitlementIsActive ?? this.entitlementIsActive,
      role: role ?? this.role,
      lastName: lastName ?? this.lastName,
      kitchenName: kitchenName ?? this.kitchenName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      activeKitchenId: activeKitchenId ?? this.activeKitchenId,
      invitationCode: invitationCode ?? this.invitationCode,
      userId: userId ?? this.userId,
      profilePictureFilePath:
          profilePictureFilePath ?? this.profilePictureFilePath,
      recipeEntity: recipeEntity ?? this.recipeEntity,
      doneSteps: doneSteps ?? this.doneSteps,
      userStorageAreas: userStorageAreas ?? this.userStorageAreas,
      userModel: userModel ?? this.userModel,
    );
  }
}
