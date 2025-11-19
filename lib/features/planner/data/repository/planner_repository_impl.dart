import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_local_datasource.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';

import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerLocalDatasource plannerLocalDatasource;
  final PlannerRemoteDatasource plannerRemoteDatasource;
  PlannerRepositoryImpl({
    required this.plannerLocalDatasource,
    required this.plannerRemoteDatasource,
  });

  @override
  Future<Either<Failure, List<MealTypeEntity>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  }) async {
    try {
      final response = await plannerRemoteDatasource.generateRecipes(
        instructions: instructions,
        kitchenId: kitchenId,
      );
      final generatedRecipes = (response as List)
          .map((e) => MealTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(generatedRecipes);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealTypeEntity>>> favouriteRecipes() async {
    try {
      final response = await plannerRemoteDatasource.favouriteRecipes();
      final generatedRecipes = (response as List)
          .map((e) => MealTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(generatedRecipes);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addToFavourite({
    required String recipeId,
  }) async {
    try {
      final response = await plannerRemoteDatasource.addToFavourite(
        recipeId: recipeId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> removeFromFavourite({
    required String recipeId,
  }) async {
    try {
      final response = await plannerRemoteDatasource.removeFromFavourite(
        recipeId: recipeId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addToWeeklyPlan({
    required MealTypeEntity mealTypeEntity,
  }) async {
    try {
      final response = await plannerLocalDatasource.addToWeeklyPlan(
        newPlan: mealTypeEntity as MealTypeModel,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealTypeEntity>>> getAllWeeklyPlans() async {
    try {
      final response = await plannerLocalDatasource.getWeeklyPlans();

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletePlan({required String id}) async {
    try {
      final response = await plannerLocalDatasource.deleteWeeklyPlan(
        selectedDate: id,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealTypeEntity>>> deleteMealTypeFromWeeklyPlan({
    required String selectedDate,
    required String mealType,
  }) async {
    try {
      final response = await plannerLocalDatasource
          .deleteMealTypeFromWeeklyPlan(
            selectedDate: selectedDate,
            mealType: mealType,
          );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  }) async {
    try {
      final response = await plannerRemoteDatasource.markRecipeFinished(
        kitchenId: kitchenId,
        recipeId: recipeId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestItems({required Pantry pantry}) async {
    try {
      String response = await plannerRemoteDatasource.requestItems(
        pantryModel: PantryModel.fromEntity(pantry),
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createMealPlan({
    required List<MealPlanEntity> mealPlans,
  }) async {
    try {
      String response = await plannerRemoteDatasource.createPlan(
        mealPlans: mealPlans,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  }) async {
    try {
      String response = await plannerRemoteDatasource.deletePlanFromRemoteDb(
        mealPlanId: mealPlanId,
        kitchenId: kitchenId,
        date: date,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  }) async {
    try {
      String response = await plannerRemoteDatasource.updateMealPlan(
        mealPlanId: mealPlanId,
        mealType: mealType,
        notes: notes,
        recipeId: recipeId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getMealByDate({
    required String kitchenId,
    required String date,
  }) async {
    try {
      String response = await plannerRemoteDatasource.getMealByDate(
        kitchenId: kitchenId,
        date: date,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealTypeEntity>>> listAllMealPlans({
    required String kitchenId,
  }) async {
    try {
      logInfo("Fetching meal plans for kitchenId: $kitchenId");

      final response = await plannerRemoteDatasource.listAllMealPlans(
        kitchenId: kitchenId,
      );

      final generatedRecipes = (response as List).map((e) {
        return MealTypeModel.fromJson(e as Map<String, dynamic>);
      }).toList();

      for (var element in generatedRecipes) {
        logInfo("Generated recipesd: ${element.toJson()}");
      }

      return Right(generatedRecipes);
    } on Failure catch (f) {
      logInfo("Failure: ${f.message}");
      return Left(f);
    } catch (e) {
      logInfo("Error: ${e.toString()}");
      return Left(UnknownFailure(e.toString()));
    }
  }
}
