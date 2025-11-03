import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';

import 'package:foodkitchen/features/profile/domain/usecases/get_profile_picture.dart';
import 'package:foodkitchen/features/profile/domain/usecases/set_profile_picture.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserCubit _userCubit;
  final SetProfilePicture _setProfilePicture;
  final GetProfilePicture _getProfilePicture;

  ProfileBloc({
    required UserCubit userCubit,
    required SetProfilePicture setProfilePicture,
    required GetProfilePicture getProfilePicture,
  }) : _userCubit = userCubit,
       _setProfilePicture = setProfilePicture,
       _getProfilePicture = getProfilePicture,
       super(const ProfileState()) {
    on<LoadProfilePicture>(_onLoadProfilePicture);
    on<UpdateProfilePicture>(_onUpdateProfilePicture);
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
        _userCubit.updateUserProfilePicture();
      },
    );
  }
}
