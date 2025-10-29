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
