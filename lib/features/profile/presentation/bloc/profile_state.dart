import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final Uint8List? imagePath;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.imagePath,
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileState copyWith({
    Uint8List? imagePath,
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
