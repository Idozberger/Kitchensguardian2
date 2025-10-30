import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
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
import 'package:go_router/go_router.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
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
import 'widgets/bottom_nav_recipe_details.dart';

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
  late final PlannerBloc plannerBloc;
  late MealTypeEntity recipe;

  bool isFav = false;
  int selectedTab = 0;
  List<Map<String, dynamic>> steps = [];

  @override
  void initState() {
    super.initState();
    plannerBloc = context.read<PlannerBloc>();
    recipe = widget.mealTypeEntity;
    isFav = recipe.available;
    initlizeSteps();
  }

  void initlizeSteps() {
    if (plannerBloc.state.startRecipe) {
      steps = plannerBloc.state.doneSteps;
    } else {
      steps = recipe.cookingSteps
          .map((step) => {"step": step, "completed": false})
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBarWidget(),
      body: SafeArea(
        child: BlocConsumer<PlannerBloc, PlannerState>(
          listener: (_, state) {
            if (state.successMessage.isNotEmpty) {
              AppToast.show(state.successMessage, ToastType.success);
            }
          },
          builder: (_, state) => _buildContent(context, state),
        ),
      ),
      bottomNavigationBar: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return state.startRecipe && selectedTab == 1
              ? BottomNavRecipeDetails(steps: steps)
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlannerState state) {
    return SingleChildScrollView(
      child: Column(
        spacing: h(14),
        children: [
          _buildHeader(),
          RecipeInfoWidget(recipe: recipe),
          _buildPrimaryActions(context, state),
          _buildTabs(),
          _buildTabContent(state),
          gap(height: 14),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return HeaderImageWidget(
      isFav: isFav,
      onFavoriteToggle: () {
        setState(() => isFav = !isFav);
        plannerBloc.add(
          isFav
              ? AddToFavouriteRecipeEvent(recipe.id)
              : RemoveFromFavouriteRecipeEvent(recipe.id),
        );
      },
    );
  }

  Widget _buildPrimaryActions(BuildContext context, PlannerState state) {
    return PrimaryActionsWidget(
      recipe: recipe,
      isPlan: widget.isPlan,
      startRecipe: state.startRecipe,
      isFinishing: state.isFinishingRecipe,
      addToWeeklyPlanCallback: () => _handleAddToWeeklyPlan(context, state),
      onStartRecipe: () async {
        plannerBloc.add(
          UpdateStartRecipeEvent(
            startRecipe: true,
            mealTypeEntity: [recipe],
            doneSteps: steps,
          ),
        );
        await NotificationService().showRecipeInProgressNotification(
          mealTypeModel: recipe as MealTypeModel,
          recipeName: recipe.title,
        );

        setState(() => selectedTab = 1);
      },
      onCancel: () {
        plannerBloc.add(
          UpdateStartRecipeEvent(
            startRecipe: false,
            mealTypeEntity: [],
            doneSteps: [],
          ),
        );
        setState(() => steps.forEach((step) => step["completed"] = false));
      },
      onFinish: () {
        plannerBloc.add(
          MarkRecipeFinishedEvent(
            kitchenId: context.read<UserCubit>().state.activeKitchenId,
            recipeId: recipe.id,
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return SecondaryActionsWidget(
      selectedIndex: selectedTab,
      onTabSelected: (index) => setState(() => selectedTab = index),
    );
  }

  Widget _buildTabContent(PlannerState state) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: selectedTab == 0 ? _buildIngredientsTab() : _buildStepsTab(state),
    );
  }

  Widget _buildIngredientsTab() {
    return Column(
      children: [
        IngredientsListWidget(recipe: recipe),
        gap(height: 16),
        if (recipe.missingItems) MissingItemsListWidget(),
      ],
    );
  }

  Widget _buildStepsTab(PlannerState state) {
    return Column(
      children: [
        RecipeSummaryTile(recipe: recipe),
        gap(height: 15),

        RecipeStepsTile(
          recipe: recipe,
          steps: steps,
          startRecipe: state.startRecipe,
          onStepToggle: _handleStepToggle,
        ),
      ],
    );
  }

  Future<void> _handleAddToWeeklyPlan(
    BuildContext context,
    PlannerState state,
  ) async {
    final existingPlans = state.getAllWeeklyPlans;
    final plannerBloc = context.read<PlannerBloc>();
    final alreadyPlanned = existingPlans.any(
      (plan) => plan.date == recipe.formatedDateString,
    );

    if (!AppConstants.entitlementIsActive) {
      AppToast.show("Subscription required!", ToastType.error);
      context.push(Routes.subscription);
      return;
    }

    if (alreadyPlanned || existingPlans.length < 3) {
      plannerBloc.add(AddToWeeklyPlanEvent(recipe));
      context.go(Routes.dashboard);
    } else {
      AppToast.show(
        "You can only create plans for 3 days in advance.",
        ToastType.error,
      );
      context.push(Routes.subscription);
    }
  }

  Future<void> _handleStepToggle(int index, bool isCompleted) async {
    final startRecipe = plannerBloc.state.startRecipe;

    if (!startRecipe) {
      AppToast.show(
        "Start the recipe first before proceeding to the steps!",
        ToastType.warning,
      );
      return;
    }

    if (isCompleted) {
      final uncheck = await _confirmUncheckDialog();
      if (uncheck == true) {
        setState(() => steps[index]["completed"] = false);
      }
    } else {
      setState(() => steps[index]["completed"] = true);
      if (steps.every((step) => step["completed"])) {
        CompleteDialogWidget.show(
          context,
          onConfirm: () {
            plannerBloc.add(
              UpdateStartRecipeEvent(
                startRecipe: false,
                mealTypeEntity: [],
                doneSteps: [],
              ),
            );
            setState(() => steps.forEach((step) => step["completed"] = false));
            AppToast.show("You’ve finished the recipe!", ToastType.success);
          },
        );
      }
    }
  }

  Future<bool?> _confirmUncheckDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (_) => GenericDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Uncheck Step",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            gap(height: 12),
            Text(
              "Are you sure you want to mark this step as incomplete?",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// void showPersistentSnackbar(BuildContext context, MealTypeEntity recipe) {
//   rootScaffoldMessengerKey.currentState?.showSnackBar(
//     SnackBar(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(h(12)),
//         side: BorderSide(color: AppColors.primaryColor),
//       ),
//       elevation: 1,
//       content: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Recipe Under Making',
//             style: Theme.of(context).textTheme.headlineLarge,
//           ),
//           gap(height: 4),
//           Text(recipe.title, style: Theme.of(context).textTheme.headlineMedium),
//         ],
//       ),
//       dismissDirection: DismissDirection.none,
//       duration: const Duration(days: 1),
//       behavior: SnackBarBehavior.fixed,
//       backgroundColor: Colors.white,
//       action: SnackBarAction(
//         textColor: AppColors.primaryColor,
//         label: 'Go to Recipe',
//         onPressed: () {
//           final context = rootNavigatorKey.currentContext;
//           context!.pushNamed(
//             Routes.generateRecipesDetails,
//             extra: {"meal_type_entity": recipe, "is_plan": false},
//           );
//           rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
//         },
//       ),
//     ),
//   );
// }
