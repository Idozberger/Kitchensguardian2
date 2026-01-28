import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

final class PlannerState {
  final List<RecipeEntity>? recipes;
  final List<RecipeEntity>? favouriteRecipes;
  final List<RecipeEntity> startedRecipe;
  final List<MergedRecipePlanEntity> getAllWeeklyPlans;
  final List<MergedRecipePlanEntity> dateBasedPlan;
  final List<Map<String, dynamic>> doneSteps;
  final List<MergedRecipePlanEntity> mealPlans;
  final List<MergedRecipePlanEntity> editMealsPlans;
  final String? startDate;
  final String? endDate;
  final bool isLoading;
  final bool loadingPlans;
  final bool isSubscribed;
  final bool addingToWeeklyPlan;
  final bool startRecipe;
  final bool isFinishingRecipe;
  final bool isRecipeFinished;
  final String? errorMessage;
  final String successMessage;
  final int mealTypeSelectedIndex;
  final DateTime? selectedDate;

  const PlannerState({
    this.recipes,
    this.favouriteRecipes,
    this.getAllWeeklyPlans = const [],
    this.startedRecipe = const [],
    this.editMealsPlans = const [],
    this.mealPlans = const [],
    this.isLoading = false,
    this.isSubscribed = false,
    this.startRecipe = false,
    this.loadingPlans = true,
    this.isFinishingRecipe = false,
    this.addingToWeeklyPlan = false,
    this.isRecipeFinished = false,
    this.errorMessage,
    this.successMessage = "",
    this.dateBasedPlan = const [],
    this.doneSteps = const [],
    this.mealTypeSelectedIndex = 0,
    this.selectedDate,
    this.startDate,
    this.endDate,
  });

  PlannerState copyWith({
    List<RecipeEntity>? recipes,
    List<MergedRecipePlanEntity>? mealPlans,
    List<RecipeEntity>? favouriteRecipes,
    List<MergedRecipePlanEntity>? getAllWeeklyPlans,
    List<MergedRecipePlanEntity>? dateBasedPlan,
    List<RecipeEntity>? startedRecipe,
    List<MergedRecipePlanEntity>? editMealsPlans,
    bool? isLoading,
    bool? isFinishingRecipe,
    bool? startRecipe,
    bool? loadingPlans,
    bool? addingToWeeklyPlan,
    bool? isSubscribed,
    String? errorMessage,
    bool? isRecipeFinished,
    String? successMessage,
    List<Map<String, dynamic>>? doneSteps,
    int? mealTypeSelectedIndex,
    DateTime? selectedDate,
    String? startDate,
    String? endDate,
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
      editMealsPlans: editMealsPlans ?? this.editMealsPlans,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      loadingPlans: loadingPlans ?? this.loadingPlans,
      isRecipeFinished: isRecipeFinished ?? this.isRecipeFinished,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}
