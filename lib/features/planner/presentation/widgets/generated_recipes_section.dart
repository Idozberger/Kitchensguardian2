import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';

/// Sliver version of the generated recipes card - see [SavedRecipesSection]
/// for why this renders as a `DecoratedSliver` + `SliverList` instead of a
/// boxed `UpperTile` + shrinkWrap `ListView.separated`.
class GeneratedRecipesSection extends StatelessWidget {
  final PlannerState state;
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;
  final bool isEdit;

  const GeneratedRecipesSection({
    super.key,
    required this.state,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (state.recipes == null || state.recipes!.isEmpty) {
      return const SliverToBoxAdapter();
    }

    final recipes = state.recipes!;
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
                    "Generated Recipes",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  gap(height: 14),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) return gap(height: 6);
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
