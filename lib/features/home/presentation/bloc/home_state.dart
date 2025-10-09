import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final dynamic kitchenData;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.kitchenData,
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    dynamic kitchenData,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      kitchenData: kitchenData ?? this.kitchenData,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    kitchenData,
  ];
}
