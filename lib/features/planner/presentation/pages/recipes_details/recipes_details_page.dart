import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
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
  final bool isEdit;

  const RecipesDetailsPage({
    super.key,
    required this.mealTypeEntity,
    required this.isPlan,
    required this.isEdit,
  });

  @override
  State<RecipesDetailsPage> createState() => _RecipesDetailsPageState();
}

class _RecipesDetailsPageState extends State<RecipesDetailsPage> {
  late final PlannerBloc plannerBloc;
  late MealTypeEntity recipe;

  bool addPlanDummyLoading = false;
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
          gap(height: 18),
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
      thumbnail: recipe.thumbnail,
    );
  }

  Widget _buildPrimaryActions(BuildContext context, PlannerState state) {
    return PrimaryActionsWidget(
      addPlanDummyLoading: addPlanDummyLoading,
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
        // ignore: avoid_function_literals_in_foreach_calls
        setState(() => steps.forEach((step) => step["completed"] = false));
      },
      onFinish: () {
        plannerBloc.add(
          UpdateStartRecipeEvent(
            startRecipe: false,
            mealTypeEntity: [],
            doneSteps: [],
          ),
        );
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
        if (recipe.missingItems)
          MissingItemsListWidget(ingredients: recipe.ingredients),
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

    setState(() {
      addPlanDummyLoading = true;
    });
    plannerBloc.add(
      AddMealPlanEvent(
        date: widget.mealTypeEntity.formatedDateString,
        kitchenId: context.read<UserCubit>().state.activeKitchenId,
        mealPlan: recipe,
      ),
    );
    await Future.delayed(Duration(seconds: 1));

    if (widget.isEdit) {
      context.push(Routes.editMeal);
    } else {
      context.push(Routes.addMeal);
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
            // ignore: avoid_function_literals_in_foreach_calls
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
