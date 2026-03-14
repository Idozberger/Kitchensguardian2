import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/entities/kitchen_date_range_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PlannerRepository {
  Future<Either<Failure, List<RecipeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  });
  Future<Either<Failure, List<RecipeEntity>>> favouriteRecipes();
  Future<Either<Failure, String>> addToFavourite({required String recipeId});
  Future<Either<Failure, String>> removeFromFavourite({
    required String recipeId,
  });
  Future<Either<Failure, String>> addToWeeklyPlan({
    required RecipeEntity recipeEntity,
  });
  Future<Either<Failure, List<RecipeEntity>>> getAllWeeklyPlans();
  Future<Either<Failure, List<RecipeEntity>>> deleteMealTypeFromWeeklyPlan({
    required String selectedDate,
    required String mealType,
  });
  Future<Either<Failure, String>> deletePlan({required String id});
  Future<Either<Failure, String>> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  });
  Future<Either<Failure, bool>> checkMissingIngredients({
    required String kitchenId,
    required String recipeId,
  });
  Future<Either<Failure, String>> requestItems({required Pantry pantry});
  Future<Either<Failure, String>> createMealPlan({
    required List<MealPlanEntity> mealPlans,
  });
  Future<Either<Failure, String>> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  });
  Future<Either<Failure, String>> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  });
  Future<Either<Failure, String>> getMealByDate({
    required String kitchenId,
    required String date,
  });
  Future<Either<Failure, List<RecipeEntity>>> listAllMealPlans({
    required String kitchenId,
  });
  Future<Either<Failure, KitchenDateRangeEntity>> getDateRange({
    required String kitchenId,
  });
  Future<Either<Failure, KitchenDateRangeEntity>> setDateRange({
    required String kitchenId,
    required String startDate,
    required String endDate,
  });
}
