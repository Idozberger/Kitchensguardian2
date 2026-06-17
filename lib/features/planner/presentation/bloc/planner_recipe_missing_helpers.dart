import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

RecipeEntity? recipeWithRemovedMissingIngredients(
  RecipeModel? recipe,
  List<IngredientEntity> selectedIngredients,
  String recipeId,
) {
  if (recipe == null || recipe.id != recipeId) return recipe;

  final updatedMissingIngredients = List<IngredientEntity>.from(
    recipe.missingIngredients,
  );

  for (var ingredient in selectedIngredients) {
    updatedMissingIngredients.removeWhere((i) => i.name == ingredient.name);
  }

  return recipe.copyWith(missingIngredients: updatedMissingIngredients);
}
