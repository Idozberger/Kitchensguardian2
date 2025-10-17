import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/home/domain/entities/pantries_items.dart';

class HomeState {
  final bool isLoading;
  final bool loadingWeeklyPlans;
  final String? errorMessage;
  final String? successMessage;
  final dynamic kitchenData;
  final List<PantriesItemsEntity> pantryItems;
  final List<MealTypeEntity> dateBasedPlan;
  const HomeState({
    this.isLoading = false,
    this.loadingWeeklyPlans = false,
    this.errorMessage,
    this.successMessage,
    this.kitchenData,
    this.pantryItems = const [],
    this.dateBasedPlan = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? loadingWeeklyPlans,
    String? errorMessage,
    List<PantriesItemsEntity>? pantryItems,
    List<MealTypeEntity>? dateBasedPlan,
    String? successMessage,
    dynamic kitchenData,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      loadingWeeklyPlans: loadingWeeklyPlans ?? this.loadingWeeklyPlans,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pantryItems: pantryItems ?? this.pantryItems,
      kitchenData: kitchenData ?? this.kitchenData,
      dateBasedPlan: dateBasedPlan ?? this.dateBasedPlan,
    );
  }
}
