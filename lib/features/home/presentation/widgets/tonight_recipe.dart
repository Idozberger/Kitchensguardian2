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
    _pageController = PageController(viewportFraction: 0.88, initialPage: 0);
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
        final todayFormatted = formatDate(DateTime.now());
        final todayRecipes = state.dateBasedPlan
            .where((recipe) => recipe.formatedDateString == todayFormatted)
            .toList();

        // Define meal order
        const mealOrder = ["Breakfast", "Lunch", "Dinner"];

        todayRecipes.sort((a, b) {
          final aIndex = mealOrder.indexOf(a.mealType);
          final bIndex = mealOrder.indexOf(b.mealType);
          return aIndex.compareTo(bIndex);
        });

        return UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today Plan",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
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
                          context.push(Routes.addMeal);
                        },
                        child: Text("Find Recipes"),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: h(300),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: PageView.builder(
                      padEnds: false,

                      controller: _pageController,
                      itemCount: todayRecipes.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final recipe = todayRecipes[index];
                        return Padding(
                          padding: EdgeInsets.only(right: w(14)),
                          child: RecipeCard(
                            isTodayPlan: true,
                            mealType: recipe.mealType,
                            title: recipe.title,
                            description: recipe.recipeShortSummary,
                            imagePath: AppAssets.onBoardingSliderBg01,
                            onTap: () {
                              context.pushNamed(
                                Routes.generateRecipesDetails,
                                extra: {
                                  "meal_type_entity": recipe,
                                  "is_plan": false,
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  todayRecipes.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: w(4)),
                    width: _currentPage == index ? w(8) : w(8),
                    height: h(8),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryColor
                          : const Color(0xffD4D2D2),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
