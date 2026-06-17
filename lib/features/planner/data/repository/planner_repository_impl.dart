// ignore_for_file: non_constant_identifier_names
// Backend JSON uses snake_case keys mapped without renaming.

import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_local_datasource.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';
import 'package:foodkitchen/features/planner/data/models/kitchen_date_range_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/kitchen_date_range_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

part 'planner_repository_impl_part.dart';
part 'planner_repository_impl_part2.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDatasource plannerLocalDatasource;
  final PlannerRemoteDatasource plannerRemoteDatasource;
  PlannerRepositoryImpl({
    required this.plannerLocalDatasource,
    required this.plannerRemoteDatasource,
  });

  @override
  Future<Either<Failure, List<RecipeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  }) => _plannerRepoImplGenerateRecipes(
    this,
    instructions: instructions,
    kitchenId: kitchenId,
  );

  @override
  Future<Either<Failure, List<RecipeEntity>>> favouriteRecipes({
    required String kitchenId,
  }) => _plannerRepoImplFavouriteRecipes(this, kitchenId: kitchenId);

  @override
  Future<Either<Failure, String>> addToFavourite({
    required String recipeId,
    required String kitchenId,
  }) => _plannerRepoImplAddToFavourite(
    this,
    recipeId: recipeId,
    kitchenId: kitchenId,
  );

  @override
  Future<Either<Failure, String>> removeFromFavourite({
    required String recipeId,
    required String kitchenId,
  }) => _plannerRepoImplRemoveFromFavourite(
    this,
    recipeId: recipeId,
    kitchenId: kitchenId,
  );

  @override
  Future<Either<Failure, String>> addToWeeklyPlan({
    required RecipeEntity recipeEntity,
  }) => _plannerRepoImplAddToWeeklyPlan(this, recipeEntity: recipeEntity);

  @override
  Future<Either<Failure, List<RecipeEntity>>> getAllWeeklyPlans() =>
      _plannerRepoImplGetAllWeeklyPlans(this);

  @override
  Future<Either<Failure, String>> deletePlan({required String id}) =>
      _plannerRepoImplDeletePlan(this, id: id);

  @override
  Future<Either<Failure, List<RecipeEntity>>> deleteMealTypeFromWeeklyPlan({
    required String selectedDate,
    required String mealType,
  }) => _plannerRepoImplDeleteMealTypeFromWeeklyPlan(
    this,
    selectedDate: selectedDate,
    mealType: mealType,
  );

  @override
  Future<Either<Failure, String>> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  }) => _plannerRepoImplMarkRecipeFinished(
    this,
    kitchenId: kitchenId,
    recipeId: recipeId,
  );

  @override
  Future<Either<Failure, String>> requestItems({required Pantry pantry}) =>
      _plannerRepoImplRequestItems(this, pantry: pantry);

  @override
  Future<Either<Failure, String>> createMealPlan({
    required List<MealPlanEntity> mealPlans,
  }) => _plannerRepoImplCreateMealPlan(this, mealPlans: mealPlans);

  @override
  Future<Either<Failure, String>> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  }) => _plannerRepoImplDeletePlanFromRemoteDb(
    this,
    mealPlanId: mealPlanId,
    kitchenId: kitchenId,
    date: date,
  );

  @override
  Future<Either<Failure, String>> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  }) => _plannerRepoImplUpdateMealPlan(
    this,
    mealPlanId: mealPlanId,
    mealType: mealType,
    notes: notes,
    recipeId: recipeId,
  );

  @override
  Future<Either<Failure, String>> getMealByDate({
    required String kitchenId,
    required String date,
  }) => _plannerRepoImplGetMealByDate(this, kitchenId: kitchenId, date: date);

  @override
  Future<Either<Failure, List<RecipeEntity>>> listAllMealPlans({
    required String kitchenId,
  }) => _plannerRepoImplListAllMealPlans(this, kitchenId: kitchenId);

  @override
  Future<Either<Failure, KitchenDateRangeEntity>> getDateRange({
    required String kitchenId,
  }) => _plannerRepoImplGetDateRange(this, kitchenId: kitchenId);

  @override
  Future<Either<Failure, KitchenDateRangeEntity>> setDateRange({
    required String kitchenId,
    required String startDate,
    required String endDate,
  }) => _plannerRepoImplSetDateRange(
    this,
    kitchenId: kitchenId,
    startDate: startDate,
    endDate: endDate,
  );

  @override
  Future<Either<Failure, bool>> checkMissingIngredients({
    required String kitchenId,
    required String recipeId,
  }) => _plannerRepoImplCheckMissingIngredients(
    this,
    kitchenId: kitchenId,
    recipeId: recipeId,
  );
}
