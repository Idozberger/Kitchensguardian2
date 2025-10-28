import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/app_base.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
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
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          if (plannerBloc.state.startRecipe) {
            showPersistentSnackbar(context, recipe);
          } else {
            rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar(
              reason: SnackBarClosedReason.dismiss,
            );
          }
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9F9F9),
        appBar: AppBarWidget(),
        body: SafeArea(
          child: BlocConsumer<PlannerBloc, PlannerState>(
            listener: (_, state) {
              if (state.successMessage.isNotEmpty) {
                AppToast.show(state.successMessage, ToastType.success);
              }
            },
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
                      startRecipe: state.startRecipe,
                      addToWeeklyPlanCallback: () async {
                        final plannerBloc = context.read<PlannerBloc>();
                        final existingPlans = state.getAllWeeklyPlans;

                        bool exists = existingPlans.any(
                          (plan) => plan.date == recipe.formatedDateString,
                        );

                        if (AppConstants.entitlementIsActive) {
                          plannerBloc.add(AddToWeeklyPlanEvent(recipe));
                        }
                        if (exists || existingPlans.length < 3) {
                          // Add the recipe to weekly plan
                          plannerBloc.add(AddToWeeklyPlanEvent(recipe));

                          if (context.mounted) {
                            context.go(Routes.dashboard);
                          }
                        } else {
                          AppToast.show(
                            "You can only create plans for 3 days in advance.",
                            ToastType.error,
                          );
                          context.push(Routes.subscription);
                        }
                      },
                      onStartRecipe: () {
                        plannerBloc.add(
                          UpdateStartRecipeEvent(startRecipe: true),
                        );

                        setState(() {
                          secondaryActionSelectedIndex = 1;
                        });
                      },
                      isFinishing: state.isFinishingRecipe,
                      onCancel: () {
                        plannerBloc.add(
                          UpdateStartRecipeEvent(startRecipe: false),
                        );
                        setState(() {
                          steps = steps.map((step) {
                            step["completed"] = false;
                            return step;
                          }).toList();
                        });
                        rootScaffoldMessengerKey.currentState
                            ?.removeCurrentSnackBar(
                              reason: SnackBarClosedReason.dismiss,
                            );
                      },
                      onFinish: () {
                        plannerBloc.add(
                          MarkRecipeFinishedEvent(
                            kitchenId: context
                                .read<UserCubit>()
                                .state
                                .activeKitchenId,
                            recipeId: recipe.id,
                          ),
                        );
                        rootScaffoldMessengerKey.currentState
                            ?.removeCurrentSnackBar(
                              reason: SnackBarClosedReason.dismiss,
                            );
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
                                  startRecipe: state.startRecipe,
                                  onStepToggle: (index, isCompleted) async {
                                    if (!state.startRecipe) {
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                            plannerBloc.add(
                                              UpdateStartRecipeEvent(
                                                startRecipe: false,
                                              ),
                                            );
                                            setState(() {
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
        bottomNavigationBar: BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            return state.startRecipe && secondaryActionSelectedIndex == 1
                ? BottomNavRecipeDetails(steps: steps)
                : SizedBox();
          },
        ),
      ),
    );
  }
}

void showPersistentSnackbar(BuildContext context, MealTypeEntity recipe) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(h(12)),
        side: BorderSide(color: AppColors.primaryColor),
      ),
      elevation: 1,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recipe Under making',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 4),
          Text(recipe.title, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
      dismissDirection: DismissDirection.none,
      duration: const Duration(days: 1),
      behavior: SnackBarBehavior.fixed,

      backgroundColor: Colors.white,
      action: SnackBarAction(
        textColor: AppColors.primaryColor,
        label: 'Goto Recipe',
        onPressed: () {
          final context = rootNavigatorKey.currentContext;
          context!.pushNamed(
            Routes.generateRecipesDetails,
            extra: {"meal_type_entity": recipe, "is_plan": false},
          );
          rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        },
      ),
    ),
  );
}
