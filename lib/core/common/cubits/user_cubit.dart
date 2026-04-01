import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final CommonRemoteDatasource _commonRemoteDatasource;

  UserCubit({required CommonRemoteDatasource commonRemoteDatasource})
    : _commonRemoteDatasource = commonRemoteDatasource,
      super(const UserState());
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await _commonRemoteDatasource.getProfileData();

    return response;
  }

  void updatePremiumStatus(bool isPremium) {
    emit(state.copyWith(isPremiumUser: isPremium));
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

    final Uint8List? avatarBytes = response["avatar"] is Uint8List
        ? response["avatar"]
        : null;

    emit(
      state.copyWith(
        firstName: response["first_name"] ?? "",
        lastName: response["last_name"] ?? "",
        email: response["email"],
        userId: response["user_id"],
        profilePictureFilePath: avatarBytes,
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
    emit(const UserState());
  }

  Future<void> getUserStorageArea({required String kitchenId}) async {
    try {
      final response = await _commonRemoteDatasource.getAllStorageArea(
        kitchenId: kitchenId,
      );

      final storageAreas = response
          .map((json) => PantriesCommonModel.fromJson(json))
          .toList();

      emit(state.copyWith(userStorageAreas: storageAreas));
    } catch (e, stackTrace) {
      emit(state.copyWith(userStorageAreas: []));
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> updateStorageAreaToEmpty() async {
    emit(state.copyWith(userStorageAreas: []));
  }
}
