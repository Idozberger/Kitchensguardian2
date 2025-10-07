import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recipe_card.dart';

class RecommendedRecipes extends StatefulWidget {
  const RecommendedRecipes({super.key});

  @override
  State<RecommendedRecipes> createState() => _RecommendedRecipesState();
}

class _RecommendedRecipesState extends State<RecommendedRecipes> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> recipes = [
    {
      "title": "Mediterranean Grilled Chicken",
      "description": "Tender chicken with herbs, olives, and fresh vegetables.",
      "image": AppAssets.onBoardingSliderBg01,
    },
    {
      "title": "Pasta Primavera",
      "description": "Fresh veggies tossed with pasta in a light garlic sauce.",
      "image": AppAssets.onBoardingSliderBg02,
    },
    {
      "title": "Beef Stir Fry",
      "description": "Quick stir fry with beef, bell peppers, and soy sauce.",
      "image": AppAssets.onBoardingSliderBg01,
    },
  ];

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: gapSymmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recommended Recipes",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              SvgPicture.asset(AppAssets.recipesSvg),
            ],
          ),
        ),
        SizedBox(height: h(20)),
        SizedBox(
          height: h(300),
          child: Align(
            alignment: Alignment.topLeft,
            child: PageView.builder(
              padEnds: false,
              controller: _pageController,
              itemCount: recipes.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Padding(
                  padding: EdgeInsets.only(left: w(20)),
                  child: RecipeCard(
                    title: recipe["title"]!,
                    description: recipe["description"]!,
                    imagePath: recipe["image"]!,
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            recipes.length,
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
    );
  }
}
