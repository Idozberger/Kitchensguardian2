import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:go_router/go_router.dart';

class RecipeTileItem extends StatelessWidget {
  final RecipeModel recipe;
  final String selectedDate;
  final String? selectedMealType;
  final bool isPlan;
  final bool canRequestToStartRecipe;
  final bool isEdit;
  final bool isDeletedIcon;
  final String svgAsset;

  final VoidCallback? deleteCallback;
  const RecipeTileItem({
    super.key,
    required this.recipe,
    required this.selectedDate,
    this.selectedMealType,
    this.canRequestToStartRecipe = false,
    required this.isPlan,
    this.svgAsset = "",
    this.isDeletedIcon = false,
    required this.isEdit,

    this.deleteCallback,
  });

  void _navigateToDetails(BuildContext context) {
    final updatedRecipe = recipe.copyWith(
      formatedDateString: selectedDate,
      mealType: selectedMealType,
    );

    context.pushNamed(
      Routes.generateRecipesDetails,
      extra: {
        "meal_type_entity": updatedRecipe,
        "is_plan": isPlan,
        "is_edit": isEdit,
        "is_request_to_start_recipe": canRequestToStartRecipe,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecipeTile(
      uint8list: recipe.thumbnail,
      title: recipe.title,
      isDeletedIcon: isDeletedIcon,
      subtitle: recipe.recipeShortSummary,
      trailingIcon: svgAsset.isEmpty
          ? AppAssets.arrowForwardAndroidSvg
          : svgAsset,
      errorText: recipe.missingIngredients.isNotEmpty
          ? "Some items are missing"
          : "",
      selected: false,
      onTap: () => _navigateToDetails(context),
      onTrailingTap: () {
        if (isDeletedIcon) {
          deleteCallback?.call();
        } else {
          _navigateToDetails(context);
        }
      },
    );
  }
}
