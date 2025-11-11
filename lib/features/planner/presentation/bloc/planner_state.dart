import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

final class PlannerState {
  final List<MealTypeEntity>? recipes;
  final List<MealTypeEntity>? favouriteRecipes;
  final List<MealTypeEntity> startedRecipe;
  final List<MergedMealPlanEntity> getAllWeeklyPlans;
  final List<MergedMealPlanEntity> dateBasedPlan;
  final List<Map<String, dynamic>> doneSteps;
  final List<MergedMealPlanEntity> mealPlans;
  final bool isLoading;
  final bool addingToWeeklyPlan;
  final bool startRecipe;
  final bool isFinishingRecipe;
  final String? errorMessage;
  final String successMessage;
  final int mealTypeSelectedIndex;
  final DateTime? selectedDate;
  const PlannerState({
    this.recipes,
    this.favouriteRecipes,
    this.getAllWeeklyPlans = const [],
    this.startedRecipe = const [],
    this.mealPlans = const [],
    this.isLoading = false,
    this.startRecipe = false,
    this.isFinishingRecipe = false,
    this.addingToWeeklyPlan = false,
    this.errorMessage,
    this.successMessage = "",
    this.dateBasedPlan = const [],
    this.doneSteps = const [],
    this.mealTypeSelectedIndex = 0,
    this.selectedDate,
  });

  PlannerState copyWith({
    List<MealTypeEntity>? recipes,
    List<MergedMealPlanEntity>? mealPlans,
    List<MealTypeEntity>? favouriteRecipes,
    List<MergedMealPlanEntity>? getAllWeeklyPlans,
    List<MergedMealPlanEntity>? dateBasedPlan,
    List<MealTypeEntity>? startedRecipe,
    bool? isLoading,
    bool? isFinishingRecipe,
    bool? startRecipe,
    bool? addingToWeeklyPlan,
    String? errorMessage,
    String? successMessage,
    List<Map<String, dynamic>>? doneSteps,
    int? mealTypeSelectedIndex,
    DateTime? selectedDate,
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
      startRecipe: startRecipe ?? this.startRecipe,
      isFinishingRecipe: isFinishingRecipe ?? this.isFinishingRecipe,
      startedRecipe: startedRecipe ?? this.startedRecipe,
      doneSteps: doneSteps ?? this.doneSteps,
      mealPlans: mealPlans ?? this.mealPlans,
      mealTypeSelectedIndex:
          mealTypeSelectedIndex ?? this.mealTypeSelectedIndex,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
