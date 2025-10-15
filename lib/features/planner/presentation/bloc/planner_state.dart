import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';

final class PlannerState {
  final List<MealTypeEntity>? recipes;
  final List<MealTypeEntity>? favouriteRecipes;
  final List<MealTypeEntity>? getAllWeeklyPlans;
  final bool isLoading;
  final bool addingToWeeklyPlan;
  final String? errorMessage;
  final String successMessage;
  const PlannerState({
    this.recipes,
    this.favouriteRecipes,
    this.getAllWeeklyPlans,
    this.isLoading = false,
    this.addingToWeeklyPlan = false,
    this.errorMessage,
    this.successMessage = "",
  });

  PlannerState copyWith({
    List<MealTypeEntity>? recipes,
    List<MealTypeEntity>? favouriteRecipes,
    List<MealTypeEntity>? getAllWeeklyPlans,
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
    );
  }
}
