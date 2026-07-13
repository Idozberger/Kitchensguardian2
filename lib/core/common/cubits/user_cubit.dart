import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/datasource/unit_system_local_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/common/entitlement/user_entitlement_snapshot.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_unit_system.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/set_unit_system.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({
    required CommonRemoteDatasource commonRemoteDatasource,
    required UserEntitlementSnapshot entitlementSnapshot,
    required UnitSystemLocalDataSource unitSystemLocalDataSource,
    required GetUnitSystem getUnitSystem,
    required SetUnitSystem setUnitSystem,
  }) : _commonRemoteDatasource = commonRemoteDatasource,
       _entitlementSnapshot = entitlementSnapshot,
       _unitSystemLocalDataSource = unitSystemLocalDataSource,
       _getUnitSystem = getUnitSystem,
       _setUnitSystem = setUnitSystem,
       super(const UserState());

  final CommonRemoteDatasource _commonRemoteDatasource;
  final UserEntitlementSnapshot _entitlementSnapshot;
  final UnitSystemLocalDataSource _unitSystemLocalDataSource;
  final GetUnitSystem _getUnitSystem;
  final SetUnitSystem _setUnitSystem;

  bool _backendProfileEntitlement = false;
  bool _manualPremiumDev = false;

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await _commonRemoteDatasource.getProfileData();
    return response;
  }

  void updatePremiumStatus(bool isPremium) {
    _manualPremiumDev = isPremium;
    _recomputePremiumAccess();
  }

  void setGoogleSignUpUserModel({
    required String firstName,
    required String lastName,
    required String email,
    String? userId,
    Uint8List? profilePicture,
  }) async {
    emit(
      state.copyWith(
        userModel: UserModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: "",
        ),
      ),
    );
  }

  Future<void> setUser() async {
    final response = await fetchUserProfile();
    _backendProfileEntitlement = response['entitlement_is_active'] == true;

    final Object? avatarRaw = response['avatar'];
    final Uint8List? avatarBytes = avatarRaw is Uint8List ? avatarRaw : null;

    emit(
      state.copyWith(
        firstName: (response['first_name'] as String?) ?? '',
        lastName: (response['last_name'] as String?) ?? '',
        email: response['email'] as String?,
        userId: response['user_id'] as String?,
        profilePictureFilePath: avatarBytes,
        // Missing key (e.g. profile fetch failed) keeps the fail-safe default
        // of true so the intro carousel is never re-shown by mistake.
        onboardingCompleted:
            (response['onboarding_completed'] as bool?) ?? true,
      ),
    );
    _recomputePremiumAccess();
  }

  /// Marks the post-signup intro flow as completed — optimistically in state,
  /// then persisted on the backend so it survives re-login and other devices.
  Future<void> completeOnboarding() async {
    if (state.onboardingCompleted) return;
    emit(state.copyWith(onboardingCompleted: true));
    try {
      await _commonRemoteDatasource.completeOnboarding();
    } catch (e) {
      devLog('completeOnboarding failed: $e');
    }
  }

  void _recomputePremiumAccess() {
    const hasPremiumAccess = true;
    final isSubscribed = _backendProfileEntitlement || _manualPremiumDev;
    _entitlementSnapshot.hasPremiumAccess = hasPremiumAccess;
    if (hasPremiumAccess == state.hasPremiumAccess &&
        isSubscribed == state.isPremiumUser &&
        isSubscribed == state.entitlementIsActive) {
      return;
    }
    emit(
      state.copyWith(
        hasPremiumAccess: hasPremiumAccess,
        isPremiumUser: isSubscribed,
        entitlementIsActive: isSubscribed,
      ),
    );
  }

  void updateActiveKitchenIdInvitationCodeAndRole({
    required String activeKitchenId,
    required String kitchenName,
    required String invitationCode,
    required String role,
    Uint8List? avatarBytes,
  }) {
    emit(
      state.copyWith(
        kitchenName: kitchenName,
        activeKitchenId: activeKitchenId,
        invitationCode: invitationCode,
        role: role,
        profilePictureFilePath: avatarBytes,
      ),
    );
  }

  /// Resolves and applies the active kitchen's measurement system (KG-7/KG-8).
  ///
  /// 1. Synchronously seeds from [fromKitchen] (the `unit_system` carried by a
  ///    kitchen switch) or the local cache, so dropdowns are correct on the
  ///    first frame — even offline / before any network call.
  /// 2. Persists the resolved value to the per-kitchen cache.
  /// 3. Refreshes from the backend (authoritative; catches changes made on
  ///    another device via KG-6), updating state + cache if it differs.
  Future<void> applyUnitSystemForKitchen({
    required String kitchenId,
    String? fromKitchen,
  }) async {
    if (kitchenId.isEmpty) return;

    final cached = _unitSystemLocalDataSource.read(kitchenId: kitchenId);
    final seed = (fromKitchen != null && fromKitchen.trim().isNotEmpty)
        ? fromKitchen
        : cached;

    if (seed != null && seed.trim().isNotEmpty) {
      final system = unitSystemFromApi(seed);
      if (!isClosed) emit(state.copyWith(unitSystem: system));
      await _unitSystemLocalDataSource.cache(
        kitchenId: kitchenId,
        unitSystem: unitSystemToApi(system),
      );
    }

    final result = await _getUnitSystem(
      GetUnitSystemParams(kitchenId: kitchenId),
    );
    await result.match(
      (failure) async => devLog('getUnitSystem failed: $failure'),
      (value) async {
        final system = unitSystemFromApi(value);
        await _unitSystemLocalDataSource.cache(
          kitchenId: kitchenId,
          unitSystem: unitSystemToApi(system),
        );
        // Only reflect if this is still the active kitchen.
        if (!isClosed && state.activeKitchenId == kitchenId) {
          emit(state.copyWith(unitSystem: system));
        }
      },
    );
  }

  /// Changes the active kitchen's measurement system (BRD UC-04, host only).
  ///
  /// Persists to the backend first; only on success does it emit + cache, so a
  /// rejected write (e.g. non-host) never leaves the UI showing a system the
  /// backend did not accept. Storage stays metric — existing pantry, recipe and
  /// grocery values surface in the new system on the next read.
  ///
  /// Returns `null` on success, or the user-facing error message on failure.
  Future<String?> changeUnitSystemForActiveKitchen(UnitSystem system) async {
    final kitchenId = state.activeKitchenId;
    if (kitchenId.isEmpty) return 'No active kitchen.';
    if (state.unitSystem == system) return null;

    final result = await _setUnitSystem(
      SetUnitSystemParams(kitchenId: kitchenId, unitSystem: system),
    );

    return result.match(
      (failure) {
        devLog('setUnitSystem failed: $failure');
        return failure.userMessage;
      },
      (value) {
        final applied = unitSystemFromApi(value);
        _unitSystemLocalDataSource.cache(
          kitchenId: kitchenId,
          unitSystem: unitSystemToApi(applied),
        );
        if (!isClosed && state.activeKitchenId == kitchenId) {
          emit(state.copyWith(unitSystem: applied));
        }
        return null;
      },
    );
  }

  Future<void> updateUserProfilePicture(Uint8List avatarBytes) async {
    emit(state.copyWith(profilePictureFilePath: avatarBytes));
  }

  void updateUserProfileNames({
    required String firstName,
    required String lastName,
  }) {
    emit(state.copyWith(firstName: firstName, lastName: lastName));
  }

  Future<void> updateKitchenIdAndRefferalCode(
    String kitchenId,
    String refferalCode,
  ) async {
    emit(
      state.copyWith(activeKitchenId: kitchenId, invitationCode: refferalCode),
    );
  }

  Future<void> updateRecipeEntity(List<RecipeEntity> recipeEntity) async {
    emit(state.copyWith(recipeEntity: recipeEntity));
  }

  void toggleLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  void clearUser() {
    _backendProfileEntitlement = false;
    _manualPremiumDev = false;
    _entitlementSnapshot.hasPremiumAccess = true;
    emit(const UserState());
  }

  Future<void> updateStorageAreaToEmpty() async {
    emit(state.copyWith(userStorageAreas: []));
  }

  Future<void> getUserStorageArea({required String kitchenId}) async {
    try {
      final response = await _commonRemoteDatasource.getAllStorageArea(
        kitchenId: kitchenId,
      );

      final storageAreas = response.map(PantriesCommonModel.fromJson).toList();

      emit(state.copyWith(userStorageAreas: storageAreas));
    } catch (e, stackTrace) {
      emit(state.copyWith(userStorageAreas: []));
      devPrint(stackTrace.toString());
    }
  }
}
