import 'dart:typed_data';

class ProfileState {
  final Uint8List? imagePath;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.imagePath,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    Uint8List? imagePath,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      imagePath: imagePath ?? this.imagePath,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
