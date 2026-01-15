import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';

class SuggestionRecipes extends StatelessWidget {
  const SuggestionRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) => UpperTile(
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _buildHeader(context),
            if (state.suggestedRecipe.isEmpty)
              _buildEmptyState(context)
            else
              _buildRecipeCard(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Suggestion Recipe",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
        SvgPicture.asset(AppAssets.recipesSvg),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      "No suggestion recipes available at the moment. Please check back later.",
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildRecipeCard(BuildContext context, HomeState state) {
    final recipe = state.suggestedRecipe.first;
    return Padding(
      padding: gapOnly(top: 12),
      child: RecipeCard(
        width: double.infinity,
        isTodayPlan: false,
        mealType: recipe.mealType,
        title: recipe.title,
        description: recipe.recipeShortSummary,
        imageBytes: recipe.thumbnail,
        onTap: () => _handleRecipeTap(context, recipe),
      ),
    );
  }

  void _handleRecipeTap(BuildContext context, dynamic recipe) {
    context.pushNamed(
      Routes.generateRecipesDetails,
      extra: {"meal_type_entity": recipe, "is_plan": false, "is_edit": false},
    );
  }
}
