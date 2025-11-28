import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';

class SuggestionRecipes extends StatelessWidget {
  const SuggestionRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        return UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Suggestion Recipe",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  SvgPicture.asset(AppAssets.recipesSvg),
                ],
              ),
              gap(height: 8),
              if (state.dateBasedPlan.isEmpty)
                Text(
                  "No suggestion recipes available at the moment. Please check back later.",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              if (state.dateBasedPlan.isNotEmpty)
                RecipeCard(
                  width: double.infinity,
                  isTodayPlan: false,
                  mealType: state.dateBasedPlan.first.mealType,
                  title: state.dateBasedPlan.first.title,
                  description: state.dateBasedPlan.first.recipeShortSummary,
                  imageBytes: state.dateBasedPlan.first.thumbnail,
                  onTap: () {
                    context.pushNamed(
                      Routes.generateRecipesDetails,
                      extra: {
                        "meal_type_entity": state.dateBasedPlan.first,
                        "is_plan": false,
                        "is_edit": false,
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
