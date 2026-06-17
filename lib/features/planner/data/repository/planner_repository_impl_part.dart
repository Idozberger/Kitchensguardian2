// ignore_for_file: non_constant_identifier_names
part of 'package:foodkitchen/features/planner/data/repository/planner_repository_impl.dart';

Future<Either<Failure, List<RecipeEntity>>> _plannerRepoImplGenerateRecipes(
  PlannerRepositoryImpl r, {
  required String instructions,
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.generateRecipes(
      instructions: instructions,
      kitchenId: kitchenId,
    );
    final generatedRecipes = (response as List)
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return Right(generatedRecipes);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, List<RecipeEntity>>> _plannerRepoImplFavouriteRecipes(
  PlannerRepositoryImpl r, {
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.favouriteRecipes(
      kitchenId: kitchenId,
    );
    final generatedRecipes = (response as List)
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return Right(generatedRecipes);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplAddToFavourite(
  PlannerRepositoryImpl r, {
  required String recipeId,
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.addToFavourite(
      recipeId: recipeId,
      kitchenId: kitchenId,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplRemoveFromFavourite(
  PlannerRepositoryImpl r, {
  required String recipeId,
  required String kitchenId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.removeFromFavourite(
      recipeId: recipeId,
      kitchenId: kitchenId,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplAddToWeeklyPlan(
  PlannerRepositoryImpl r, {
  required RecipeEntity recipeEntity,
}) async {
  try {
    final response = await r.plannerLocalDatasource.addToWeeklyPlan(
      newPlan: recipeEntity as RecipeModel,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, List<RecipeEntity>>> _plannerRepoImplGetAllWeeklyPlans(
  PlannerRepositoryImpl r,
) async {
  try {
    final response = await r.plannerLocalDatasource.getWeeklyPlans();

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplDeletePlan(
  PlannerRepositoryImpl r, {
  required String id,
}) async {
  try {
    final response = await r.plannerLocalDatasource.deleteWeeklyPlan(
      selectedDate: id,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, List<RecipeEntity>>>
_plannerRepoImplDeleteMealTypeFromWeeklyPlan(
  PlannerRepositoryImpl r, {
  required String selectedDate,
  required String mealType,
}) async {
  try {
    final response = await r.plannerLocalDatasource
        .deleteMealTypeFromWeeklyPlan(
          selectedDate: selectedDate,
          mealType: mealType,
        );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplMarkRecipeFinished(
  PlannerRepositoryImpl r, {
  required String kitchenId,
  required String recipeId,
}) async {
  try {
    final response = await r.plannerRemoteDatasource.markRecipeFinished(
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

Future<Either<Failure, String>> _plannerRepoImplRequestItems(
  PlannerRepositoryImpl r, {
  required Pantry pantry,
}) async {
  try {
    String response = await r.plannerRemoteDatasource.requestItems(
      pantryModel: PantryModel.fromEntity(pantry),
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplCreateMealPlan(
  PlannerRepositoryImpl r, {
  required List<MealPlanEntity> mealPlans,
}) async {
  try {
    String response = await r.plannerRemoteDatasource.createPlan(
      mealPlans: mealPlans,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplDeletePlanFromRemoteDb(
  PlannerRepositoryImpl r, {
  required String mealPlanId,
  required String kitchenId,
  required String date,
}) async {
  try {
    String response = await r.plannerRemoteDatasource.deletePlanFromRemoteDb(
      mealPlanId: mealPlanId,
      kitchenId: kitchenId,
      date: date,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplUpdateMealPlan(
  PlannerRepositoryImpl r, {
  required String mealPlanId,
  required String mealType,
  required String notes,
  required String recipeId,
}) async {
  try {
    String response = await r.plannerRemoteDatasource.updateMealPlan(
      mealPlanId: mealPlanId,
      mealType: mealType,
      notes: notes,
      recipeId: recipeId,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}

Future<Either<Failure, String>> _plannerRepoImplGetMealByDate(
  PlannerRepositoryImpl r, {
  required String kitchenId,
  required String date,
}) async {
  try {
    String response = await r.plannerRemoteDatasource.getMealByDate(
      kitchenId: kitchenId,
      date: date,
    );

    return Right(response);
  } on Failure catch (f) {
    return Left(f);
  } catch (e) {
    return Left(unknownFailureFrom(e));
  }
}
