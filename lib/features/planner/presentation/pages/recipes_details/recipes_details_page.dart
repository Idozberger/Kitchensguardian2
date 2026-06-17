// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls
// Async navigation after awaits; legacy locals; forEach closures kept for readability.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
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
import 'package:go_router/go_router.dart';

import 'widgets/bottom_nav_recipe_details.dart';

part 'recipes_details_page_part.dart';

class RecipesDetailsPage extends StatefulWidget {
  final RecipeEntity recipeEntity;
  final bool isPlan;
  final bool isRequestToStartRecipe;
  final bool isEdit;

  const RecipesDetailsPage({
    super.key,
    required this.recipeEntity,
    required this.isPlan,
    required this.isEdit,
    required this.isRequestToStartRecipe,
  });

  @override
  State<RecipesDetailsPage> createState() => _RecipesDetailsPageState();
}

class _RecipesDetailsPageState extends State<RecipesDetailsPage> {
  late final PlannerBloc plannerBloc;

  late RecipeEntity recipe;

  bool addPlanDummyLoading = false;
  bool isFav = false;
  int selectedTab = 0;
  int inProgressRecipeIndex = -1;
  String inProgressRecipeId = '';
  List<Map<String, dynamic>> steps = [];

  @override
  void initState() {
    super.initState();
    plannerBloc = context.read<PlannerBloc>();
    recipe = widget.recipeEntity;
    isFav = recipe.available;
    _initializeSteps();
  }

  void _initializeSteps() {
    plannerBloc.add(UpdateRecipeFinishedState());

    inProgressRecipeId = widget.recipeEntity.recipeId.isEmpty
        ? widget.recipeEntity.id
        : widget.recipeEntity.recipeId;

    inProgressRecipeIndex = plannerBloc.state.startedRecipe.indexWhere(
      (r) =>
          r.recipeId == inProgressRecipeId ||
          (r.recipeId.isEmpty && r.id == inProgressRecipeId),
    );

    final isInProgress = inProgressRecipeIndex != -1;
    final hasDoneSteps =
        inProgressRecipeIndex < plannerBloc.state.doneSteps.length;

    steps = isInProgress && hasDoneSteps
        ? plannerBloc.state.doneSteps[inProgressRecipeIndex]
        : recipe.cookingSteps
              .map((step) => {'step': step, 'completed': false})
              .toList();
  }

  bool get _isRecipeInProgress => plannerBloc.state.startedRecipe.any(
    (r) =>
        r.recipeId == inProgressRecipeId ||
        (r.recipeId.isEmpty && r.id == inProgressRecipeId),
  );

  String get _activeRecipeId =>
      recipe.recipeId.isEmpty ? recipe.id : recipe.recipeId;

  void _setRecipesDetailsTab(int index) {
    setState(() => selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBarWidget(onNavigatorback: () => context.pop()),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: _onStateChanged,
        builder: (_, state) => buildRecipesDetailsContent(context, state),
      ),
      bottomNavigationBar: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) => buildRecipesDetailsBottomNav(state),
      ),
    );
  }

  void _onStateChanged(BuildContext context, PlannerState state) {
    if (state.successMessage.isNotEmpty) {
      AppToast.show(state.successMessage, ToastType.success);
    }

    if (state.isRecipeFinished) {
      context.pop();
      _handleCancelRecipe();
    }
  }

  void _toggleFavourite() {
    setState(() => isFav = !isFav);
    plannerBloc.add(
      isFav
          ? AddToFavouriteRecipeEvent(
              kitchenId: context.read<UserCubit>().state.activeKitchenId,
              recipeId: recipe.id,
            )
          : RemoveFromFavouriteRecipeEvent(
              kitchenId: context.read<UserCubit>().state.activeKitchenId,
              recipeId: recipe.id,
            ),
    );
  }

  void _handleStartOrRequest(PlannerState state) {
    final isMember = context.read<UserCubit>().state.role == 'member';

    if (isMember) {
      devLog('recipe-recipeId: ${recipe.recipeId} - recipe-id: ${recipe.id}');
      plannerBloc.add(
        RequestStartRecipeEvent(
          recipeId: widget.recipeEntity.recipeId,
          kitchenId: context.read<UserCubit>().state.activeKitchenId,
          recipeName: widget.recipeEntity.title,
        ),
      );
    } else {
      plannerBloc.add(
        UpdateStartRecipeEvent(
          startRecipe: true,
          recipeEntity: [...state.startedRecipe, recipe as RecipeModel],
          doneSteps: steps,
        ),
      );
      setState(() => selectedTab = 1);
    }
  }

  void _handleCancelRecipe() {
    inProgressRecipeId = widget.recipeEntity.recipeId.isEmpty
        ? widget.recipeEntity.id
        : widget.recipeEntity.recipeId;
    inProgressRecipeIndex = plannerBloc.state.startedRecipe.indexWhere(
      (r) =>
          r.recipeId == inProgressRecipeId ||
          (r.recipeId.isEmpty && r.id == inProgressRecipeId),
    );

    plannerBloc.add(
      CancelInProgressRecipeEvent(inProgressRecipeIndex: inProgressRecipeIndex),
    );
    setState(() => steps.forEach((step) => step['completed'] = false));
  }

  Future<void> _handleAddToWeeklyPlan(
    BuildContext context,
    PlannerState state,
  ) async {
    setState(() => addPlanDummyLoading = true);

    plannerBloc.add(
      AddMealPlanEvent(
        date: widget.recipeEntity.formatedDateString,
        kitchenId: context.read<UserCubit>().state.activeKitchenId,
        mealPlan: recipe as RecipeModel,
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 1));

    widget.isEdit
        ? context.push(Routes.editMeal)
        : context.push(Routes.addMeal);
  }

  Future<void> _handleStepToggle(int index, bool isCompleted) async {
    if (!_isRecipeInProgress) {
      AppToast.show(
        'Start the recipe first before proceeding to the steps!',
        ToastType.warning,
      );
      return;
    }

    if (isCompleted) {
      final confirmed = await showRecipesDetailsUncheckStepDialog();
      if (confirmed == true) {
        setState(() => steps[index]['completed'] = false);
      }
    } else {
      setState(() => steps[index]['completed'] = true);

      final allStepsDone = steps.every(
        (Map<String, dynamic> step) => readJsonBool(step, 'completed'),
      );
      if (allStepsDone) {
        CompleteDialogWidget.show(
          context,
          onFinish: () => plannerBloc.add(
            MarkRecipeFinishedEvent(
              kitchenId: context.read<UserCubit>().state.activeKitchenId,
              recipeId: _activeRecipeId,
            ),
          ),
        );
      }
    }
  }

  void _clearRecipesDetailsStepsCompleted() {
    setState(() => steps.forEach((step) => step['completed'] = false));
  }
}
