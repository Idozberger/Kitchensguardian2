import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_step_tile.dart';
import 'package:go_router/go_router.dart';

class GeneratedRecipesDetailPage extends StatefulWidget {
  final MealTypeEntity mealTypeEntity;
  final bool isPlan;
  const GeneratedRecipesDetailPage({
    super.key,
    required this.mealTypeEntity,
    required this.isPlan,
  });

  @override
  State<GeneratedRecipesDetailPage> createState() =>
      _GeneratedRecipesDetailPageState();
}

class _GeneratedRecipesDetailPageState
    extends State<GeneratedRecipesDetailPage> {
  late PlannerBloc plannerBloc;
  late MealTypeEntity recipe;
  bool isFav = false;
  int secondaryActionSelectedIndex = 0;
  bool startRecipe = false;

  List<Map<String, dynamic>> steps = [];

  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    recipe = widget.mealTypeEntity;
    isFav = recipe.available;
    steps = recipe.cookingSteps
        .map((step) => {"step": step, "completed": false})
        .toList();
    super.initState();
  }

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
                  recipe.missingItems
                      ? _buildMissingItemsList(context)
                      : SizedBox(),
                ] else
                  _buildRecipesAndStepList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          startRecipe == false || secondaryActionSelectedIndex == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 20),
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
                        "0${steps.where((step) => step["completed"] == true).length}/0${steps.length}",
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
            onTap: () => context.pop(),
          ),
        ],
      ),
      title: Text(
        "Generated Recipe",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildHeaderImage() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
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
            onTap: state.isLoading
                ? null
                : () {
                    setState(() => isFav = !isFav);
                    if (isFav) {
                      plannerBloc.add(AddToFavouriteRecipeEvent(recipe.id));
                    } else {
                      plannerBloc.add(
                        RemoveFromFavouriteRecipeEvent(recipe.id),
                      );
                    }
                  },
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: state.isLoading
                  ? Transform.scale(
                      scale: 0.5,
                      child: CircularProgressIndicator(),
                    )
                  : SvgPicture.asset(
                      isFav
                          ? AppAssets.favouriteFilledSvg
                          : AppAssets.favouriteSvg,
                      height: h(14),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeInfo(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          recipe.missingItems
              ? Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    "Some items are missing*",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
                      fontSize: t(10),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SizedBox(),
          Text(recipe.title, style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 15),
          _buildInfoRow(AppAssets.gramSvg, recipe.calories, context),
          gap(height: 15),
          _buildInfoRow(AppAssets.stopWatchSvg, recipe.cookingTime, context),
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
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
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
                      if (recipe.missingItems == false) {
                        setState(() {
                          startRecipe = true;
                          secondaryActionSelectedIndex = 1;
                        });
                      } else {
                        AppToast.show(
                          "Some ingredients are missing, so the recipe can't be started.",
                          ToastType.error,
                        );
                      }
                    },
                    text: "Start Recipe",
                  ),

            if (widget.isPlan) ...[
              gap(height: 20),
              SizedBox(
                width: double.infinity,
                height: h(40),
                child: OutlinedButton(
                  onPressed: () {
                    if (AppConstants.entitlementIsActive) {
                      plannerBloc.add(AddToWeeklyPlanEvent(recipe));
                    } else if (state.getAllWeeklyPlans.length < 3) {
                      plannerBloc.add(AddToWeeklyPlanEvent(recipe));
                    } else {
                      AppToast.show(
                        "You can only add up to 3 weekly plans.",
                        ToastType.error,
                      );
                      context.push(Routes.subscription);
                    }
                  },
                  child: state.addingToWeeklyPlan
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        )
                      : Text(
                          "Add to Weekly Meal Plan",
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: t(14),
                                color: AppColors.primaryColor,
                              ),
                        ),
                ),
              ),
            ],
          ],
        );
      },
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
    final ingredients = recipe.ingredients;

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
                "${item.amount} ${item.unit} ${item.name}",
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
          Text(
            "Request List",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(10)),
          Text(
            "Request host to buy missing items",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(15),
              color: Color(0xff787878),
            ),
          ),
          SizedBox(height: h(20)),
          GenericButtonWidget(onPressed: () {}, text: "Request Now"),
        ],
      ),
    );

    // return UpperTile(
    //   widget: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Text(
    //             "Missing Items",
    //             style: Theme.of(context).textTheme.headlineLarge,
    //           ),
    //           TextButton(
    //             onPressed: () {},
    //             child: Text(
    //               "Select All",
    //               style: Theme.of(context).textTheme.headlineMedium!.copyWith(
    //                 color: AppColors.primaryColor,
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //       gap(height: 14),
    //       GenericCircleCheckboxTile(
    //         title: '1/2 tsp cayenne pepper',
    //         isChecked: true,
    //         onChanged: (bool value) {},
    //         activeColor: AppColors.primaryColor,
    //       ),
    //       gap(height: 14),
    //       GenericCircleCheckboxTile(
    //         title: '1 egg',
    //         isChecked: true,
    //         onChanged: (bool value) {},
    //         activeColor: AppColors.primaryColor,
    //       ),
    //       gap(height: 14),
    //       GenericCircleCheckboxTile(
    //         title: '1 cup buttermilk',
    //         isChecked: false,
    //         onChanged: (bool value) {},
    //         activeColor: AppColors.primaryColor,
    //       ),
    //       gap(height: 15),
    //       GenericButtonWidget(onPressed: () {}, text: "Add in List"),
    //     ],
    //   ),
    // );
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
                recipe.recipeShortSummary,
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
                recipe.title,
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
                        if (startRecipe) {
                          setState(() {
                            steps[index]["completed"] =
                                !steps[index]["completed"];
                          });
                        } else {
                          AppToast.show(
                            "Start the recipe first before proceeding to the steps!",
                            ToastType.warning,
                          );
                        }
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
