import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final String? imagePath;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.imagePath,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    String? imagePath,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [imagePath, isLoading, errorMessage];
}
