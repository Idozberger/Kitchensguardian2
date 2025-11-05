import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/config/routes.dart';

class RecipeTileItem extends StatelessWidget {
  final MealTypeModel recipe;
  final String selectedDate;
  final String? selectedMealType;
  final bool isPlan;
  final bool isDeletedIcon;
  final String svgAsset;

  final VoidCallback? deleteCallback;
  const RecipeTileItem({
    super.key,
    required this.recipe,
    required this.selectedDate,
    this.selectedMealType,
    required this.isPlan,
    this.svgAsset = "",
    this.isDeletedIcon = false,

    this.deleteCallback,
  });

  void _navigateToDetails(BuildContext context) {
    if (context.read<PlannerBloc>().state.startRecipe == false) {
      final updatedRecipe = recipe.copyWith(
        formatedDateString: selectedDate,
        mealType: selectedMealType,
      );

      context.pushNamed(
        Routes.generateRecipesDetails,
        extra: {"meal_type_entity": updatedRecipe, "is_plan": isPlan},
      );
    } else {
      AppToast.show(
        "A recipe is already in progress. Please finish it first, or tap 'Go to Recipe' at the bottom.",
        ToastType.error,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
      );
    }
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
      errorText: recipe.missingItems ? "Some items are missing" : "",
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
