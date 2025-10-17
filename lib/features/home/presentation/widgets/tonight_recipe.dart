import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
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
  final today = DateTime.now();
  List<MealTypeEntity> filteredPlans = [];
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
              else if (state.dateBasedPlan.isEmpty)
                Center(
                  child: Text(
                    "No upcoming recipes found",
                    style: Theme.of(context).textTheme.headlineMedium,
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
                      itemCount: state.dateBasedPlan.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final recipe = state.dateBasedPlan[index];

                        return Padding(
                          padding: EdgeInsets.only(left: w(20)),
                          child: RecipeCard(
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

              if (filteredPlans.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    filteredPlans.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: w(4)),
                      width: w(8),
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
