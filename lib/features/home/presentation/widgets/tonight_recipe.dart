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
  static const _mealOrder = ["breakfast", "lunch", "dinner"];

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

  List<dynamic> _getTodayRecipes(HomeState state) {
    final todayFormatted = formatDateToMeetBackendDate(DateTime.now());
    final recipes = state.dateBasedPlan
        .where((r) => r.date == todayFormatted)
        .toList();

    recipes.sort(
      (a, b) => _mealOrder
          .indexOf(a.mealType)
          .compareTo(_mealOrder.indexOf(b.mealType)),
    );

    return recipes;
  }

  void _updatePageController(int recipeCount) {
    final viewport = recipeCount == 1 ? 1.0 : 0.88;
    _pageController = PageController(
      viewportFraction: viewport,
      initialPage: _currentPage,
    );
  }

  void _navigateToRecipeDetails(dynamic recipe) {
    context.pushNamed(
      Routes.generateRecipesDetails,
      extra: {
        "meal_type_entity": recipe,
        "is_plan": false,
        "is_edit": false,
        "is_request_to_start_recipe": true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        final todayRecipes = _getTodayRecipes(state);

        if (todayRecipes.isEmpty) {
          return const SizedBox.shrink();
        }

        _updatePageController(todayRecipes.length);

        return UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: h(20)),
              _buildRecipeCarousel(todayRecipes),
              gap(height: 10),
              _buildPageIndicator(todayRecipes.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Today Plan",
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.ellipsis,
        ),
        SvgPicture.asset(AppAssets.recipesSvg),
      ],
    );
  }

  Widget _buildRecipeCarousel(List<dynamic> recipes) {
    return SizedBox(
      height: h(278),
      child: PageView.builder(
        padEnds: false,
        controller: _pageController,
        itemCount: recipes.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) =>
            _buildRecipeItem(recipes[index], recipes.length),
      ),
    );
  }

  Widget _buildRecipeItem(dynamic recipe, int totalRecipes) {
    return Padding(
      padding: EdgeInsets.only(right: w(14)),
      child: RecipeCard(
        isTodayPlan: true,
        mealType: recipe.mealType,
        title: recipe.title,
        description: recipe.recipeShortSummary,
        imageBytes: recipe.thumbnail,
        onTap: () => _navigateToRecipeDetails(recipe),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
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
    );
  }
}
