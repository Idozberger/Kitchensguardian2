import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';

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
