import 'package:equatable/equatable.dart';
import 'package:foodkitchen/features/home/domain/entities/pantries_items.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final dynamic kitchenData;
  final List<PantriesItemsEntity> pantryItems;

  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.kitchenData,
    this.pantryItems = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<PantriesItemsEntity>? pantryItems,

    String? successMessage,
    dynamic kitchenData,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pantryItems: pantryItems ?? this.pantryItems,
      kitchenData: kitchenData ?? this.kitchenData,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    successMessage,
    kitchenData,
    pantryItems,
  ];
}
