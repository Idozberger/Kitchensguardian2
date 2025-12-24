import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/features/profile/domain/usecases/change_password.dart';
import 'package:foodkitchen/features/profile/domain/usecases/edit_profile.dart';

import 'package:foodkitchen/features/profile/domain/usecases/get_profile_picture.dart';
import 'package:foodkitchen/features/profile/domain/usecases/set_profile_picture.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserCubit _userCubit;
  final SetProfilePicture _setProfilePicture;
  final GetProfilePicture _getProfilePicture;
  final EditProfile _editProfile;
  final ChangePassword _changePassword;

  ProfileBloc({
    required UserCubit userCubit,
    required SetProfilePicture setProfilePicture,
    required GetProfilePicture getProfilePicture,
    required EditProfile editProfile,
    required ChangePassword changePassword,
  }) : _userCubit = userCubit,
       _setProfilePicture = setProfilePicture,
       _getProfilePicture = getProfilePicture,
       _editProfile = editProfile,
       _changePassword = changePassword,
       super(const ProfileState()) {
    on<LoadProfilePicture>(_onLoadProfilePicture);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
    on<EditProfileEvent>(_onEditProfile);
    on<ChangePasswordEvent>(_onChanagePassword);
  }

  Future<void> _onLoadProfilePicture(
    LoadProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getProfilePicture(NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (imagePath) {
        emit(
          state.copyWith(isLoading: false, imagePath: base64Decode(imagePath)),
        );
      },
    );
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePicture event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _setProfilePicture(
      SetProfilePictureParams(filePath: event.filePath),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (imagePath) {
        emit(
          state.copyWith(isLoading: false, imagePath: base64Decode(imagePath)),
        );
        _userCubit.updateUserProfilePicture(base64Decode(imagePath));
      },
    );
  }

  Future<void> _onEditProfile(
    EditProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _editProfile(
      EditProfileParams(
        firstName: event.firstName,
        lastName: event.lastName,
        thumbnail: event.thumbnail,
      ),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (successMessage) {
        emit(state.copyWith(isLoading: false, successMessage: successMessage));
        _userCubit.setUser();
      },
    );
  }

  Future<void> _onChanagePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _changePassword(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (successMessage) {
        emit(state.copyWith(isLoading: false, successMessage: successMessage));
      },
    );
  }
}
