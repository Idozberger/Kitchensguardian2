import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';

class HomeState {
  final bool isLoading;
  final bool loadingWeeklyPlans;
  final String? errorMessage;
  final String? successMessage;

  final List<PantriesDataEntity> pantryItems;
  final List<MealTypeEntity> dateBasedPlan;
  final List<PantriesCommonEntity> userStorageAreas;

  const HomeState({
    this.isLoading = false,
    this.loadingWeeklyPlans = false,
    this.errorMessage,
    this.successMessage,

    this.pantryItems = const [],
    this.dateBasedPlan = const [],
    this.userStorageAreas = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? loadingWeeklyPlans,
    String? errorMessage,
    List<PantriesDataEntity>? pantryItems,
    List<MealTypeEntity>? dateBasedPlan,
    String? successMessage,
    List<PantriesCommonEntity>? userStorageAreas,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      loadingWeeklyPlans: loadingWeeklyPlans ?? this.loadingWeeklyPlans,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pantryItems: pantryItems ?? this.pantryItems,
      dateBasedPlan: dateBasedPlan ?? this.dateBasedPlan,
      userStorageAreas: userStorageAreas ?? this.userStorageAreas,
    );
  }
}
