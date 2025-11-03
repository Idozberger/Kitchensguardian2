import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState());

  void setUser({
    required String firstName,
    required String lastName,
    required String email,
    required String userId,
  }) {
    emit(
      state.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        userId: userId,
      ),
    );
  }

  void updateActiveKitchenIdInvitationCodeAndRole({
    required String activeKitchenId,
    required String invitationCode,
    required String role,
  }) async {
    String? filePath = await getUserPicture();
    emit(
      state.copyWith(
        activeKitchenId: activeKitchenId,
        invitationCode: invitationCode,
        role: role,
        profilePictureFilePath: base64Decode(filePath!),
      ),
    );
  }

  Future<String?> getUserPicture() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("profile_image_path");
  }

  Future<void> updateUserProfilePicture() async {
    String? filePath = await getUserPicture();
    emit(state.copyWith(profilePictureFilePath: base64Decode(filePath!)));
  }

  Future<void> updateKitchenIdAndRefferalCode(
    String kitchenId,
    String refferalCode,
  ) async {
    emit(
      state.copyWith(activeKitchenId: kitchenId, invitationCode: refferalCode),
    );
  }

  Future<void> updateMealTypeEntity(
    List<MealTypeEntity> mealTypeEntity,
    List<Map<String, dynamic>> doneSteps,
  ) async {
    emit(state.copyWith(mealTypeEntity: mealTypeEntity, doneSteps: doneSteps));
  }

  void toggleLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }

  void clearUser() {
    emit(const UserState());
  }
}
