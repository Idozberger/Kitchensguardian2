import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:go_router/go_router.dart';

class FavouriteFoodPage extends StatefulWidget {
  const FavouriteFoodPage({super.key});

  @override
  State<FavouriteFoodPage> createState() => _FavouriteFoodPageState();
}

class _FavouriteFoodPageState extends State<FavouriteFoodPage> {
  final recipes = [
    {
      "title": "Crispy Fried Chicken",
      "subtitle": "30-40 mins ( 250 cal )",
      "image": AppAssets.onBoardingSliderBg01,
      "icon": AppAssets.arrowForwardAndroidSvg,
      "errorText": null,
    },
    {
      "title": "Golden Crispy Delig...",
      "subtitle": "15-20 mins ( 362 cal )",
      "image": AppAssets.onBoardingSliderBg02,
      "icon": AppAssets.arrowForwardAndroidSvg,
      "errorText": "Some items are missing*",
    },

    {
      "title": "Crispy Fried Chicken",
      "subtitle": "30-40 mins ( 250 cal )",
      "image": AppAssets.onBoardingSliderBg01,
      "icon": AppAssets.arrowForwardAndroidSvg,
      "errorText": null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your all favorite food list",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                ListView.builder(
                  itemCount: recipes.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Padding(
                      padding: gapOnly(top: 10),
                      child: UpperTile(
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        widget: RecipeTile(
                          onTap: () {
                            print("Tapped ${recipe["title"]}");
                          },
                          title: recipe["title"].toString(),
                          subtitle: recipe["subtitle"].toString(),
                          imagePath: recipe["image"].toString(),
                          trailingIcon: recipe["icon"].toString(),
                          errorText: recipe["errorText"]?.toString(),

                          onTrailingTap: () {
                            context.push(Routes.generateRecipesDetails);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20),
          child: GenericButtonWidget(
            onPressed: () {
              context.push(Routes.generateRecipes);
            },
            text: "Generate Recipes",
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Favorite Food",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
