import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/config/routes.dart';

class RecipeTileItem extends StatelessWidget {
  final MealTypeModel recipe;
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;

  const RecipeTileItem({
    super.key,
    required this.recipe,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
  });

  void _navigateToDetails(BuildContext context) {
    final updatedRecipe = recipe.copyWith(
      formatedDateString: selectedDate,
      mealType: selectedMealType,
    );

    logError(updatedRecipe.toJson());

    context.pushNamed(
      Routes.generateRecipesDetails,
      extra: {"meal_type_entity": updatedRecipe, "is_plan": isPlan},
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecipeTile(
      title: recipe.title,
      subtitle: recipe.recipeShortSummary,
      imagePath: AppAssets.onBoardingSliderBg01,
      trailingIcon: AppAssets.arrowForwardAndroidSvg,
      errorText: recipe.missingItems ? "Some items are missing" : "",
      selected: false,
      onTap: () => _navigateToDetails(context),
      onTrailingTap: () => _navigateToDetails(context),
    );
  }
}
