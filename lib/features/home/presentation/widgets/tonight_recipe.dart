import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TonightRecipeWidget extends StatefulWidget {
  const TonightRecipeWidget({super.key});

  @override
  State<TonightRecipeWidget> createState() => _TonightRecipeWidgetState();
}

class _TonightRecipeWidgetState extends State<TonightRecipeWidget> {
  int currentPage = 0;
  final today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        final todayFormatted = formatDate(DateTime.now());
        final todayRecipes = state.dateBasedPlan
            .where((recipe) => recipe.formatedDateString == todayFormatted)
            .toList();

        return UpperTile(
          horizontalPadding: 0,
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: gapSymmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tonight Recipes",
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                    SvgPicture.asset(AppAssets.recipesSvg),
                  ],
                ),
              ),
              SizedBox(height: h(20)),

              if (state.loadingWeeklyPlans)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              else if (todayRecipes.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(
                        "No upcoming recipes found",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      gap(height: 4),
                      TextButton(
                        onPressed: () {
                          final date = DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.now());
                          context.pushNamed(
                            Routes.generateRecipes,
                            extra: {
                              "selected_date": date,
                              "selected_meal_type": "Breakfast",
                              "is_plan": true,
                            },
                          );
                        },
                        child: Text("Find Recipes"),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: h(280),
                  child: Align(
                    alignment: Alignment.center,
                    child: RecipeCard(
                      title: todayRecipes[0].title,
                      description: todayRecipes[0].recipeShortSummary,
                      imagePath: AppAssets.onBoardingSliderBg01,
                      onTap: () {
                        context.pushNamed(
                          Routes.generateRecipesDetails,
                          extra: {
                            "meal_type_entity": todayRecipes[0],
                            "is_plan": false,
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
