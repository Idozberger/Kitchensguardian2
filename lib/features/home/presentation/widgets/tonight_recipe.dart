import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recipe_card.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:go_router/go_router.dart';

class TonightRecipeWidget extends StatefulWidget {
  const TonightRecipeWidget({super.key});

  @override
  State<TonightRecipeWidget> createState() => _TonightRecipeWidgetState();
}

class _TonightRecipeWidgetState extends State<TonightRecipeWidget> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        final todayFormatted = formatDateToMeetBackendDate(DateTime.now());
        final todayRecipes = state.dateBasedPlan
            .where((r) => r.date == todayFormatted)
            .toList();

        todayRecipes.sort((a, b) {
          const mealOrder = ["breakfast", "lunch", "dinner"];
          return mealOrder
              .indexOf(a.mealType)
              .compareTo(mealOrder.indexOf(b.mealType));
        });

        final viewport = todayRecipes.length == 1 ? 1.0 : 0.88;
        _pageController = PageController(
          viewportFraction: viewport,
          initialPage: _currentPage,
        );

        return todayRecipes.isEmpty
            ? SizedBox()
            : UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today Plan",
                          style: Theme.of(context).textTheme.headlineLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SvgPicture.asset(AppAssets.recipesSvg),
                      ],
                    ),
                    SizedBox(height: h(20)),

                    if (todayRecipes.isEmpty)
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
                                context.read<PlannerBloc>()
                                  ..add(ResetMealPlanState())
                                  ..add(
                                    UpdateTypeSelectedAndDateEvent(
                                      date: DateTime.now(),
                                      index: 0,
                                    ),
                                  );
                                context.push(Routes.addMeal);
                              },
                              child: const Text("Find Recipes"),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: h(300),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: todayRecipes.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final recipe = todayRecipes[index];
                            return Padding(
                              padding: EdgeInsets.only(right: w(14)),
                              child: FractionallySizedBox(
                                widthFactor: todayRecipes.length == 1
                                    ? 1.0
                                    : 0.88,
                                child: RecipeCard(
                                  isTodayPlan: true,
                                  mealType: recipe.mealType,
                                  title: recipe.title,
                                  description: recipe.recipeShortSummary,
                                  imageBytes: recipe.thumbnail,
                                  onTap: () {
                                    context.pushNamed(
                                      Routes.generateRecipesDetails,
                                      extra: {
                                        "meal_type_entity": recipe,
                                        "is_plan": false,
                                        "is_edit": false,
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    gap(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(todayRecipes.length, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: w(4)),
                          width: _currentPage == index ? w(8) : w(8),
                          height: h(8),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primaryColor
                                : const Color(0xffD4D2D2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
