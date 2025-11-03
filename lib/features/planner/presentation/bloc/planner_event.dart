import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/common/entities/pantry.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

sealed class PlannerEvent {}

final class GenerateRecipesEvent extends PlannerEvent {
  final String instructions;
  final String kitchenId;

  GenerateRecipesEvent({required this.instructions, required this.kitchenId});
}

final class GetFavouriteRecipesEvent extends PlannerEvent {}

final class AddToFavouriteRecipeEvent extends PlannerEvent {
  final String recipeId;
  AddToFavouriteRecipeEvent(this.recipeId);
}

final class RemoveFromFavouriteRecipeEvent extends PlannerEvent {
  final String recipeId;
  RemoveFromFavouriteRecipeEvent(this.recipeId);
}

final class ClearAiGeneratedRecipes extends PlannerEvent {}

final class AddToWeeklyPlanEvent extends PlannerEvent {
  final MealTypeEntity mealTypeEntity;
  AddToWeeklyPlanEvent(this.mealTypeEntity);
}

final class GetAllWeeklyPlansEvent extends PlannerEvent {}

final class DeletePlanEvent extends PlannerEvent {
  final String dateString;
  DeletePlanEvent(this.dateString);
}

final class GetDateBasedPlans extends PlannerEvent {
  final String dateString;
  GetDateBasedPlans(this.dateString);
}

final class DeleteMealTypeFromWeeklyPlanEvent extends PlannerEvent {
  final String selectedDate;
  final String mealType;
  DeleteMealTypeFromWeeklyPlanEvent({
    required this.selectedDate,
    required this.mealType,
  });
}

class MarkRecipeFinishedEvent extends PlannerEvent {
  final String kitchenId;
  final String recipeId;

  MarkRecipeFinishedEvent({required this.kitchenId, required this.recipeId});
}

class UpdateStartRecipeEvent extends PlannerEvent {
  final bool startRecipe;
  final List<MealTypeEntity> mealTypeEntity;
  final List<Map<String, dynamic>> doneSteps;
  UpdateStartRecipeEvent({
    required this.startRecipe,
    required this.mealTypeEntity,
    required this.doneSteps,
  });
}

final class ResetPlannerStateEvent extends PlannerEvent {}

final class AddMealPlanEvent extends PlannerEvent {
  final MealTypeEntity mealPlan;
  final String date;
  final String kitchenId;
  AddMealPlanEvent({
    required this.kitchenId,
    required this.mealPlan,
    required this.date,
  });
}

final class RequestMissingItemsEvent extends PlannerEvent {
  final Pantry pantry;
  RequestMissingItemsEvent({required this.pantry});
}

final class ResetMealPlanState extends PlannerEvent {}

final class DeleteMealPlanEvent extends PlannerEvent {
  final String mealType;
  final String date;

  DeleteMealPlanEvent({required this.mealType, required this.date});
}
