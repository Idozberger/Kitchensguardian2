import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/common/entitlement/user_entitlement_snapshot.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({
    required CommonRemoteDatasource commonRemoteDatasource,
    required UserEntitlementSnapshot entitlementSnapshot,
  }) : _commonRemoteDatasource = commonRemoteDatasource,
       _entitlementSnapshot = entitlementSnapshot,
       super(const UserState());

  final CommonRemoteDatasource _commonRemoteDatasource;
  final UserEntitlementSnapshot _entitlementSnapshot;

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
      ),
    );
    _recomputePremiumAccess();
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
