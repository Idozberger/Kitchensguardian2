import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_local_datasource.dart';
import 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';

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
}
