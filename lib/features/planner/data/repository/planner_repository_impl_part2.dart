part of 'package:foodkitchen/features/planner/data/repository/planner_repository_impl.dart';

Future<Either<Failure, List<RecipeEntity>>> _plannerRepoImplListAllMealPlans(
  PlannerRepositoryImpl r, {
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.listAllMealPlans(
      kitchenId: kitchenId,
    );

    final generatedRecipes = (response as List).map((e) {
      return RecipeModel.fromJson(e as Map<String, dynamic>);
    }).toList();

    return Right(generatedRecipes);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, KitchenDateRangeEntity>> _plannerRepoImplGetDateRange(
  PlannerRepositoryImpl r, {
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.getDateRange(
      kitchenId: kitchenId,
    );

    final model = KitchenDateRangeModel.fromJson(response);

    return Right(model);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, KitchenDateRangeEntity>> _plannerRepoImplSetDateRange(
  PlannerRepositoryImpl r, {
  required String kitchenId,
  required String startDate,
  required String endDate,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.setDateRange(
      kitchenId: kitchenId,
      startDate: startDate,
      endDate: endDate,
    );

    final model = KitchenDateRangeModel.fromJson(response);

    return Right(model);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, bool>> _plannerRepoImplCheckMissingIngredients(
  PlannerRepositoryImpl r, {
  required String kitchenId,
  required String recipeId,
}) async {
  try {
    bool response = await r.plannerRemoteDatasource.checkMissingIngredients(
      kitchenId: kitchenId,
      recipeId: recipeId,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}
