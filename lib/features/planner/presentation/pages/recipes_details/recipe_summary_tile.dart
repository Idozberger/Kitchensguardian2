import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class RecipeSummaryTile extends StatelessWidget {
  final MealTypeEntity recipe;

  const RecipeSummaryTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      color: Colors.white,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recipe", style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 8),
          Text(
            recipe.recipeShortSummary,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
