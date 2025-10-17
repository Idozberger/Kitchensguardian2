import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PlannerRepository {
  Future<Either<Failure, List<MealTypeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  });
  Future<Either<Failure, List<MealTypeEntity>>> favouriteRecipes();
  Future<Either<Failure, String>> addToFavourite({required String recipeId});
  Future<Either<Failure, String>> removeFromFavourite({
    required String recipeId,
  });
  Future<Either<Failure, String>> addToWeeklyPlan({
    required MealTypeEntity mealTypeEntity,
  });
  Future<Either<Failure, List<MealTypeEntity>>> getAllWeeklyPlans();
  Future<Either<Failure, String>> deletePlan({required String id});
}
