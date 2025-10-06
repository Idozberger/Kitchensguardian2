import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:go_router/go_router.dart';

class GenerateRecipesPage extends StatefulWidget {
  GenerateRecipesPage({super.key});

  @override
  State<GenerateRecipesPage> createState() => _GenerateRecipesPageState();
}

class _GenerateRecipesPageState extends State<GenerateRecipesPage> {
  int selectedIndex = 0;
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
      "title": "Wing Kings",
      "subtitle": "20-30 mins ( 250 cal )",
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
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              AppTextField(
                fillColor: Colors.white,
                isFilled: true,
                isLabled: false,
                label: "",
                suffixIcon: Padding(
                  padding: gapAll(h(6)),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: SvgPicture.asset(
                      AppAssets.searchSvg,
                      color: Colors.black,
                      height: h(15),
                    ),
                  ),
                ),
                hintText: "e.g Fries",
                controller: TextEditingController(),
              ),
              gap(height: 20),
              UpperTile(
                widget: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recipes.length,
                  separatorBuilder: (_, __) => gap(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeTile(
                      onTap: () {
                        print("Tapped ${recipe["title"]}");
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      title: recipe["title"].toString(),
                      subtitle: recipe["subtitle"].toString(),
                      imagePath: recipe["image"].toString(),
                      trailingIcon: recipe["icon"].toString(),
                      errorText: recipe["errorText"]?.toString(),
                      selected: index == selectedIndex,
                      onTrailingTap: () {
                        context.push(Routes.generateRecipesDetails);
                      },
                    );
                  },
                ),
              ),

              gap(height: 20),
              UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Saved Recipes",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 10),
                    Text(
                      "No Saved Recipes here! Try Generating one...",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
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
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
