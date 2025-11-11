import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfilePicture extends ProfileEvent {}

class UpdateProfilePicture extends ProfileEvent {
  final String filePath;

  const UpdateProfilePicture(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class EditProfileEvent extends ProfileEvent {
  final String firstName;
  final String lastName;

  const EditProfileEvent({required this.firstName, required this.lastName});
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}
