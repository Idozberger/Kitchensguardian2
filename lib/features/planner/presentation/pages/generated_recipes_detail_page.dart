import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_step_tile.dart';

class GeneratedRecipesDetailPage extends StatefulWidget {
  const GeneratedRecipesDetailPage({super.key});

  @override
  State<GeneratedRecipesDetailPage> createState() =>
      _GeneratedRecipesDetailPageState();
}

class _GeneratedRecipesDetailPageState
    extends State<GeneratedRecipesDetailPage> {
  bool isFav = false;
  int secondaryActionSelectedIndex = 0;
  bool startRecipe = false;
  List<Map<String, dynamic>> steps = [
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
    {
      "step": "Preheat the oil in a deep fryer or large pot to 180°C (350°F).",
      "completed": false,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                _buildHeaderImage(),
                gap(height: 20),
                _buildRecipeInfo(context),
                gap(height: 20),
                _buildPrimaryActions(context),
                gap(height: 20),
                _buildSecondaryActions(context),
                gap(height: 20),
                if (secondaryActionSelectedIndex == 0) ...[
                  _buildIngredientsList(context),
                  gap(height: 20),
                  _buildMissingItemsList(context),
                ] else
                  _buildRecipesAndStepList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: startRecipe == false
          ? null
          : SafeArea(
              child: Padding(
                padding: gapSymmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedProgressBar(
                      total: steps.length,
                      completed: steps
                          .where((step) => step["completed"] == true)
                          .length,
                    ),
                    gap(height: 6),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "${steps.length}/0${steps.where((step) => step["completed"] == true).length}",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: Colors.grey),
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
        "Generate Recipe",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      padding: gapAll(15),
      alignment: Alignment.topRight,
      height: h(154),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h(10)),
        image: DecorationImage(
          image: AssetImage(AppAssets.onBoardingSliderBg02),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        onTap: () => setState(() => isFav = !isFav),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          child: SvgPicture.asset(
            isFav ? AppAssets.favouriteFilledSvg : AppAssets.favouriteSvg,
            height: h(14),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeInfo(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              "Some items are missing*",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontSize: t(10),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "Crispy Fried Chicken",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 15),
          _buildInfoRow(AppAssets.gramSvg, "250 cal per 100 grams", context),
          gap(height: 15),
          _buildInfoRow(
            AppAssets.stopWatchSvg,
            "Cooking time: 30-40 mins",
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text, BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        SizedBox(width: w(6)),
        Text(text, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      children: [
        startRecipe
            ? Row(
                children: [
                  Flexible(
                    child: GenericButtonWidget(
                      onPressed: () {
                        setState(() {
                          startRecipe = false;
                        });
                      },
                      text: "Finish Recipe",
                      backgroundColor: Colors.white,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: w(12)),
                  Flexible(
                    child: GenericButtonWidget(
                      onPressed: () {
                        setState(() {
                          startRecipe = false;
                        });
                      },
                      text: "Cancel Recipe",
                      backgroundColor: Colors.white,
                      color: Colors.red,
                    ),
                  ),
                ],
              )
            : GenericButtonWidget(
                onPressed: () {
                  setState(() {
                    startRecipe = true;
                    secondaryActionSelectedIndex = 1;
                  });
                },
                text: "Start Recipe",
              ),

        gap(height: 20),
        SizedBox(
          width: double.infinity,
          height: h(40),
          child: OutlinedButton(
            onPressed: () {},
            child: Text(
              "Add to Weekly Meal",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(14),
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSecondaryActionButton(context, "Ingredients", 0)),
        SizedBox(width: w(10)),
        Expanded(child: _buildSecondaryActionButton(context, "Recipe", 1)),
      ],
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context,
    String label,
    int index,
  ) {
    final bool isSelected = secondaryActionSelectedIndex == index;

    return SizedBox(
      height: h(40),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryColor : null,
        ),
        onPressed: () {
          setState(() => secondaryActionSelectedIndex = index);
        },
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(14),
            color: isSelected ? Colors.black : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context) {
    final ingredients = [
      "1 kg chicken pieces (drumsticks, thighs, or wings)",
      "1 cup all-purpose flour",
      "1 tsp salt",
      "1 tsp pepper",
      "1 tsp paprika",
    ];

    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Items",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 13),
          ...ingredients.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: h(13)),
              child: Text(
                item,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingItemsList(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Missing Items",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Select All",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          gap(height: 14),
          GenericCircleCheckboxTile(
            title: '1/2 tsp cayenne pepper',
            isChecked: true,
            onChanged: (bool value) {},
            activeColor: AppColors.primaryColor,
          ),
          gap(height: 14),
          GenericCircleCheckboxTile(
            title: '1 egg',
            isChecked: true,
            onChanged: (bool value) {},
            activeColor: AppColors.primaryColor,
          ),
          gap(height: 14),
          GenericCircleCheckboxTile(
            title: '1 cup buttermilk',
            isChecked: false,
            onChanged: (bool value) {},
            activeColor: AppColors.primaryColor,
          ),
          gap(height: 15),
          GenericButtonWidget(onPressed: () {}, text: "Add in List"),
        ],
      ),
    );
  }

  Widget _buildRecipesAndStepList() {
    return Column(
      children: [
        UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recipe", style: Theme.of(context).textTheme.headlineLarge),
              gap(height: 12),
              Text(
                "Crispy Fried Chicken",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        gap(height: 20),
        UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Steps", style: Theme.of(context).textTheme.headlineLarge),
              gap(height: 15),
              Text(
                "Crispy Fried Chicken",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              gap(height: 25),
              Column(
                children: List.generate(
                  steps.length,
                  (index) => Padding(
                    padding: gapOnly(bottom: 20),
                    child: RecipeStepTile(
                      stepText: steps[index]["step"],
                      callback: () {
                        setState(() {
                          steps[index]["completed"] = true;
                        });
                      },
                      isCompleted: steps[index]["completed"],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
