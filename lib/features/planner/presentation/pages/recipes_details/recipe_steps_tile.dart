import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_step_tile.dart';

class RecipeStepsTile extends StatelessWidget {
  final MealTypeEntity recipe;
  final List<Map<String, dynamic>> steps;
  final bool startRecipe;
  final Function(int index, bool isCompleted) onStepToggle;

  const RecipeStepsTile({
    super.key,
    required this.recipe,
    required this.steps,
    required this.startRecipe,
    required this.onStepToggle,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Steps", style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 10),
          Text(recipe.title, style: Theme.of(context).textTheme.headlineMedium),
          gap(height: 10),
          Column(
            children: List.generate(
              steps.length,
              (index) => Padding(
                padding: gapOnly(bottom: 20),
                child: RecipeStepTile(
                  stepText: steps[index]["step"],
                  callback: () =>
                      onStepToggle(index, steps[index]["completed"]),
                  isCompleted: steps[index]["completed"],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
