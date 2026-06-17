import 'package:foodkitchen/features/planner/domain/datasources/recipe_start_request_firestore_datasource.dart';

class CompleteRecipeStartRequestForHostParams {
  final String hostUserId;
  final String recipeId;

  CompleteRecipeStartRequestForHostParams({
    required this.hostUserId,
    required this.recipeId,
  });
}

class CompleteRecipeStartRequestForHost {
  CompleteRecipeStartRequestForHost(this._firestore);

  final RecipeStartRequestFirestoreDatasource _firestore;

  Future<void> call(CompleteRecipeStartRequestForHostParams p) {
    return _firestore.completePendingRequestForHost(
      hostUserId: p.hostUserId,
      recipeId: p.recipeId,
    );
  }
}
