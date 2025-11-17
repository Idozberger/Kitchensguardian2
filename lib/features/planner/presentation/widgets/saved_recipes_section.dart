import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';

class SavedRecipesSection extends StatelessWidget {
  final PlannerState state;
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;

  const SavedRecipesSection({
    super.key,
    required this.state,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (state.favouriteRecipes == null || state.favouriteRecipes!.isEmpty) {
      return UpperTile(
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Saved Recipes",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            gap(height: 8),
            Text(
              "No Saved Recipes here! Try Generating one...",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      );
    }

    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Saved Recipes",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.favouriteRecipes!.length,
            separatorBuilder: (_, _) => gap(height: 10),
            itemBuilder: (_, index) {
              final recipe = state.favouriteRecipes![index];
              return RecipeTileItem(
                recipe: recipe as MealTypeModel,
                selectedDate: selectedDate,
                selectedMealType: selectedMealType,
                isPlan: isPlan,
              );
            },
          ),
        ],
      ),
    );
  }
}
