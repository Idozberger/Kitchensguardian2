part of 'package:foodkitchen/features/planner/presentation/pages/recipes_details/missing_items_list_widget.dart';

List<IngredientEntity> missingItemsResolveIngredients({
  required PlannerState plannerState,
  required List<RecipeEntity> suggestedRecipes,
  required String recipeId,
}) {
  final allRecipes = [
    ...plannerState.recipes ?? [],
    ...plannerState.favouriteRecipes ?? [],
    ...plannerState.startedRecipe,
  ];

  for (final recipe in allRecipes) {
    if (recipe.recipeId == recipeId || recipe.id == recipeId) {
      return recipe.missingIngredients;
    }
  }

  for (final weeklyPlan in plannerState.getAllWeeklyPlans) {
    final breakfast = weeklyPlan.breakfast;
    if (breakfast != null && breakfast.id == recipeId) {
      devLog("Recipe Name: ${breakfast.title}");
      return breakfast.missingIngredients;
    }

    final lunch = weeklyPlan.lunch;
    if (lunch != null && lunch.id == recipeId) {
      return lunch.missingIngredients;
    }

    final dinner = weeklyPlan.dinner;
    if (dinner != null && dinner.id == recipeId) {
      return dinner.missingIngredients;
    }
  }
  for (final recipe in suggestedRecipes) {
    if (recipe.id == recipeId) {
      return recipe.missingIngredients;
    }
  }

  return [];
}

List<PantryItem> missingItemsToPantryRows(List<IngredientEntity> selected) {
  return [
    for (final ingredient in selected)
      PantryItem(
        nameController: TextEditingController(text: ingredient.name),
        qtyController: TextEditingController(text: ingredient.amount),
        manuFacturingDate: TextEditingController(text: ""),
        expireDate: TextEditingController(text: ""),
        unit: ingredient.unit,
        pantry: null,
        file: null,
        fileBytes: null,
      ),
  ];
}

List<PantryItemEntity> missingItemsToRequestEntities(
  List<IngredientEntity> selected,
) {
  return [
    for (var i = 0; i < selected.length; i++)
      PantryItemEntity(
        name: selected[i].name,
        quantity: double.tryParse(selected[i].amount) ?? 1,
        unit: selected[i].unit,
        group: "group",
        expireDate: "",
        thumbnail: "",
        expiryStatus: '',
        stockStatus: '',
        itemId: '',
      ),
  ];
}
