import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';

final class PlannerState {
  final List<MealTypeEntity>? recipes;
  final List<MealTypeEntity>? favouriteRecipes;
  final List<MealTypeEntity> getAllWeeklyPlans;
  final MealTypeEntity? dateBasedPlan;
  final bool isLoading;
  final bool addingToWeeklyPlan;
  final String? errorMessage;
  final String successMessage;
  const PlannerState({
    this.recipes,
    this.favouriteRecipes,
    this.getAllWeeklyPlans = const [],
    this.isLoading = false,
    this.addingToWeeklyPlan = false,
    this.errorMessage,
    this.successMessage = "",
    this.dateBasedPlan,
  });

  PlannerState copyWith({
    List<MealTypeEntity>? recipes,
    List<MealTypeEntity>? favouriteRecipes,
    List<MealTypeEntity>? getAllWeeklyPlans,
    MealTypeEntity? dateBasedPlan,
    bool? isLoading,
    bool? addingToWeeklyPlan,
    String? errorMessage,
    String? successMessage,
  }) {
    return PlannerState(
      recipes: recipes ?? this.recipes,
      favouriteRecipes: favouriteRecipes ?? this.favouriteRecipes,
      getAllWeeklyPlans: getAllWeeklyPlans ?? this.getAllWeeklyPlans,
      isLoading: isLoading ?? this.isLoading,
      addingToWeeklyPlan: addingToWeeklyPlan ?? this.addingToWeeklyPlan,
      errorMessage: errorMessage ?? "",
      successMessage: successMessage ?? "",
      dateBasedPlan: dateBasedPlan ?? this.dateBasedPlan,
    );
  }
}
