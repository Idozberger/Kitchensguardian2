import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';

/// Sliver version of the saved/favourite recipes card. Renders as a
/// `SliverList` (via `DecoratedSliver` for the same card look `UpperTile`
/// gives on other screens) so a large favourites list stays lazily built
/// inside the shared `CustomScrollView` on the Generate Recipes page,
/// instead of the old shrinkWrap `ListView.separated` that built every row
/// up front.
class SavedRecipesSection extends StatelessWidget {
  final PlannerState state;
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;
  final bool isEdit;

  const SavedRecipesSection({
    super.key,
    required this.state,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (state.favouriteRecipes == null || state.favouriteRecipes!.isEmpty) {
      return SliverToBoxAdapter(
        child: UpperTile(
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
        ),
      );
    }

    final recipes = state.favouriteRecipes!;
    return DecoratedSliver(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h(14)),
        border: Border.all(color: const Color(0xffD4D2D2)),
        color: Colors.white,
      ),
      sliver: SliverPadding(
        padding: gapAll(15),
        sliver: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Saved Recipes",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  gap(height: 14),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) return gap(height: 10);
                final recipe = recipes[index ~/ 2];
                return RecipeTileItem(
                  isEdit: isEdit,
                  recipe: recipe as RecipeModel,
                  selectedDate: selectedDate,
                  selectedMealType: selectedMealType,
                  isPlan: isPlan,
                );
              }, childCount: recipes.length * 2 - 1),
            ),
          ],
        ),
      ),
    );
  }
}
