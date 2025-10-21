import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
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

class RecipesDetailsPage extends StatefulWidget {
  final MealTypeEntity mealTypeEntity;
  final bool isPlan;
  const RecipesDetailsPage({
    super.key,
    required this.mealTypeEntity,
    required this.isPlan,
  });

  @override
  State<RecipesDetailsPage> createState() => _RecipesDetailsPageState();
}

class _RecipesDetailsPageState extends State<RecipesDetailsPage> {
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
              spacing: h(14),
              children: [
                _buildHeaderImage(),

                _buildRecipeInfo(context),

                _buildPrimaryActions(context),

                _buildSecondaryActions(context),

                if (secondaryActionSelectedIndex == 0) ...[
                  _buildIngredientsList(context),
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
          : ColoredBox(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: gapSymmetric(horizontal: 20, vertical: 12),
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
                          "${steps.where((step) => step["completed"] == true).length}/${steps.length}",
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
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
        "Recipe Details",
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
                    isDisabled: recipe.missingItems,
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
            fontWeight: FontWeight.w400,
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
          GenericButtonWidget(
            onPressed: () {
              context.push(Routes.requestNow);
            },
            text: "Request Now",
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesAndStepList() {
    return Column(
      children: [
        UpperTile(
          color: Colors.white,
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recipe", style: Theme.of(context).textTheme.headlineLarge),
              gap(height: 8),
              Text(
                recipe.recipeShortSummary,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        gap(height: 15),

        UpperTile(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Steps", style: Theme.of(context).textTheme.headlineLarge),
              gap(height: 10),
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              gap(height: 10),

              Column(
                children: List.generate(
                  steps.length,
                  (index) => Padding(
                    padding: gapOnly(bottom: 20),
                    child: RecipeStepTile(
                      stepText: steps[index]["step"],
                      callback: () async {
                        if (!startRecipe) {
                          AppToast.show(
                            "Start the recipe first before proceeding to the steps!",
                            ToastType.warning,
                          );
                          return;
                        }

                        final isCompleted = steps[index]["completed"];

                        if (isCompleted) {
                          final shouldUncheck = await showDialog<bool>(
                            context: context,
                            builder: (context) => GenericDialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Uncheck Step",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: t(14),
                                        ),
                                  ),
                                  gap(height: 12),
                                  Text(
                                    "Are you sure you want to mark this step as incomplete?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: t(14),
                                        ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Yes"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (shouldUncheck == true) {
                            setState(() {
                              steps[index]["completed"] = false;
                            });
                          }
                        } else {
                          setState(() {
                            steps[index]["completed"] = true;
                          });

                          bool allCompleted = steps.every(
                            (step) => step["completed"] == true,
                          );

                          if (allCompleted) {
                            _showAllStepsCompletedDialog();
                          }
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

  void _showAllStepsCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GenericDialog(
        borderRadius: h(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Recipe Completed!",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            SizedBox(height: h(10)),
            Text(
              "You've successfully completed all the steps!",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(12),
              ),
            ),
            SizedBox(height: h(16)),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: w(147),
                height: h(40),
                child: GenericButtonWidget(
                  isLoading: false,
                  onPressed: () {
                    setState(() {
                      startRecipe = false;
                      steps = steps.map((step) {
                        step["completed"] = false;
                        return step;
                      }).toList();
                      AppToast.show(
                        "You’ve finished the recipe!",
                        ToastType.success,
                      );
                    });
                    context.pop();
                  },

                  text: "Ok",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
