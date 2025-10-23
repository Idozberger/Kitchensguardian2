import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/app_bar_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/complete_dialog_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/header_image_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/ingredients_list_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/missing_items_list_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/primary_actions_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_info_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_steps_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_summary_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/secondary_actions_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/widgets/bottom_nav_recipe_details.dart';
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

class _RecipesDetailsPageState extends State<RecipesDetailsPage>
    with SingleTickerProviderStateMixin {
  late PlannerBloc plannerBloc;
  late MealTypeEntity recipe;
  bool isFav = false;
  int secondaryActionSelectedIndex = 0;
  bool startRecipe = false;
  List<Map<String, dynamic>> steps = [];
  String? selectedMealType;
  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    recipe = widget.mealTypeEntity;
    selectedMealType = recipe.mealType;
    log("Meal Type : $selectedMealType");
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
      appBar: AppBarWidget(),
      body: SafeArea(
        child: BlocBuilder<PlannerBloc, PlannerState>(
          builder: (_, state) {
            return SingleChildScrollView(
              child: Column(
                spacing: h(14),
                children: [
                  HeaderImageWidget(
                    isFav: isFav,
                    onFavoriteToggle: () {
                      setState(() => isFav = !isFav);
                      if (isFav) {
                        plannerBloc.add(AddToFavouriteRecipeEvent(recipe.id));
                      } else {
                        plannerBloc.add(
                          RemoveFromFavouriteRecipeEvent(recipe.id),
                        );
                      }
                    },
                  ),
                  RecipeInfoWidget(recipe: recipe),
                  PrimaryActionsWidget(
                    recipe: recipe,
                    isPlan: widget.isPlan,
                    startRecipe: startRecipe,
                    addToWeeklyPlanCallback: () {
                      if (AppConstants.entitlementIsActive) {
                        context.read<PlannerBloc>().add(
                          AddToWeeklyPlanEvent(recipe),
                        );
                      } else if (state.getAllWeeklyPlans.length < 3) {
                        context.read<PlannerBloc>().add(
                          AddToWeeklyPlanEvent(recipe),
                        );
                      } else {
                        AppToast.show(
                          "You can only add up to 3 weekly plans.",
                          ToastType.error,
                        );
                        context.push(Routes.subscription);
                      }
                    },
                    onStartRecipe: () {
                      setState(() {
                        startRecipe = true;
                        secondaryActionSelectedIndex = 1;
                      });
                    },
                    onFinishOrCancel: () {
                      setState(() => startRecipe = false);
                    },
                  ),
                  SecondaryActionsWidget(
                    selectedIndex: secondaryActionSelectedIndex,
                    onTabSelected: (index) {
                      setState(() => secondaryActionSelectedIndex = index);
                    },
                  ),
                  Padding(
                    padding: gapSymmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        if (secondaryActionSelectedIndex == 0) ...[
                          IngredientsListWidget(recipe: recipe),
                          gap(height: 16),
                          if (recipe.missingItems) MissingItemsListWidget(),
                        ] else
                          Column(
                            children: [
                              RecipeSummaryTile(recipe: recipe),
                              gap(height: 15),
                              RecipeStepsTile(
                                recipe: recipe,
                                steps: steps,
                                startRecipe: startRecipe,
                                onStepToggle: (index, isCompleted) async {
                                  if (!startRecipe) {
                                    AppToast.show(
                                      "Start the recipe first before proceeding to the steps!",
                                      ToastType.warning,
                                    );
                                    return;
                                  }
                                  if (isCompleted) {
                                    final shouldUncheck = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => GenericDialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        false,
                                                      ),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        context,
                                                        true,
                                                      ),
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
                                      CompleteDialogWidget.show(
                                        context,
                                        onConfirm: () {
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
                                        },
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: startRecipe && secondaryActionSelectedIndex == 1
          ? BottomNavRecipeDetails(steps: steps)
          : null,
    );
  }
}
