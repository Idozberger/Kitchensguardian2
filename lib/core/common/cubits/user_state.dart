import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
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
  final bool isPremiumUser;
  final bool hasPremiumAccess;
  final List<RecipeEntity> recipeEntity;
  final List<List<Map<String, dynamic>>> doneSteps;
  final List<PantriesCommonEntity> userStorageAreas;
  final UserModel? userModel;

  /// Whether the user has finished the post-signup intro flow (feature
  /// carousel). Defaults to true so the carousel is never shown before the
  /// profile has loaded; the backend flag is authoritative.
  final bool onboardingCompleted;

  /// Active kitchen's measurement system (KG-7/KG-8). Defaults to metric —
  /// the backend default — until a kitchen's `unit_system` is resolved.
  final UnitSystem unitSystem;

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
    this.isPremiumUser = false,
    this.hasPremiumAccess = true,
    this.activeKitchenId = '',
    this.invitationCode = '',
    this.recipeEntity = const [],
    this.doneSteps = const [],
    this.userStorageAreas = const [],
    this.userModel,
    this.onboardingCompleted = true,
    this.unitSystem = UnitSystem.metric,
  });

  UserState copyWith({
    String? firstName,
    String? kitchenName,
    bool? entitlementIsActive,
    bool? isPremiumUser,
    bool? hasPremiumAccess,
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
    bool? onboardingCompleted,
    UnitSystem? unitSystem,
  }) {
    return UserState(
      firstName: firstName ?? this.firstName,
      entitlementIsActive: entitlementIsActive ?? this.entitlementIsActive,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      hasPremiumAccess: hasPremiumAccess ?? this.hasPremiumAccess,
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
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      unitSystem: unitSystem ?? this.unitSystem,
    );
  }
}
