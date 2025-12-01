import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';

import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final CommonRemoteDatasource _commonRemoteDatasource;

  UserCubit({required CommonRemoteDatasource commonRemoteDatasource})
    : _commonRemoteDatasource = commonRemoteDatasource,
      super(const UserState());
  Future<Uint8List?> fetchUserAvatar() async {
    final bytes = await _commonRemoteDatasource.getUserAvatar();
    emit(state.copyWith(profilePictureFilePath: bytes));
    return bytes;
  }

  void setUser({
    required String firstName,
    required String lastName,
    String? email,
    String? userId,
    Uint8List? profilePicture,
  }) async {
    Uint8List? imageBytes = await fetchUserAvatar();
    emit(
      state.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        userId: userId,
        profilePictureFilePath: imageBytes,
      ),
    );
  }

  void updateActiveKitchenIdInvitationCodeAndRole({
    required String activeKitchenId,
    required String invitationCode,
    required String role,
    Uint8List? avatarBytes,
  }) {
    emit(
      state.copyWith(
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

  Future<void> updateRecipeEntity(
    List<RecipeEntity> RecipeEntity,
    List<Map<String, dynamic>> doneSteps,
  ) async {
    emit(state.copyWith(recipeEntity: RecipeEntity, doneSteps: doneSteps));
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
