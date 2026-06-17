// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls
// Async navigation after awaits; legacy locals; forEach closures kept for readability.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/recipes_request_details/recipes_request_details_loading_view.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/recipes_request_details/recipes_request_details_uncheck_step_dialog.dart';
import 'package:foodkitchen/features/planner/domain/usecases/complete_recipe_start_request_for_host.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/app_bar_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/complete_dialog_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/header_image_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/ingredients_list_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/primary_actions_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_info_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_steps_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipe_summary_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/secondary_actions_widget.dart';
import 'package:foodkitchen/features/planner/presentation/pages/recipes_details/widgets/bottom_nav_recipe_details.dart';
import 'package:go_router/go_router.dart';

part 'recipes_request_details_page_part.dart';

class RecipesRequestDetailsPage extends StatefulWidget {
  final String recipeId;
  final String kitchenId;
  final String isCompleted;
  final bool backPageAvailable;

  const RecipesRequestDetailsPage({
    super.key,
    required this.recipeId,
    required this.kitchenId,
    this.backPageAvailable = true,
    this.isCompleted = "pending",
  });

  @override
  State<RecipesRequestDetailsPage> createState() =>
      _RecipesRequestDetailsPageState();
}

class _RecipesRequestDetailsPageState extends State<RecipesRequestDetailsPage> {
  late final PlannerBloc _plannerBloc;
  late final DashboardBloc _dashboardBloc;
  int inProgressRecipeIndex = -1;
  String inProgressRecipeId = "";
  RecipeEntity? _recipe;

  bool _isFav = false;
  int _selectedTab = 0;
  List<Map<String, dynamic>> _steps = [];
  late final CompleteRecipeStartRequestForHost
  _completeRecipeStartRequestForHost;

  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();
    _dashboardBloc = context.read<DashboardBloc>();
    _completeRecipeStartRequestForHost = sl();

    _dashboardBloc.add(
      GetRecipeDetailsEvent(
        recipeId: widget.recipeId,
        kitchenId: widget.kitchenId,
      ),
    );
  }

  void _initRecipe(RecipeEntity recipe) {
    _recipe = recipe;
    _isFav = recipe.available;
    _initializeSteps(recipe);
  }

  void _initializeSteps(RecipeEntity recipe) {
    _plannerBloc.add(UpdateRecipeFinishedState());

    inProgressRecipeId = recipe.recipeId.isEmpty ? recipe.id : recipe.recipeId;
    inProgressRecipeIndex = _plannerBloc.state.startedRecipe.indexWhere(
      (recipe) =>
          recipe.recipeId == inProgressRecipeId ||
          (recipe.recipeId.isEmpty && recipe.id == inProgressRecipeId),
    );
    if (inProgressRecipeIndex != -1) {
      _steps = (inProgressRecipeIndex < _plannerBloc.state.doneSteps.length)
          ? _plannerBloc.state.doneSteps[inProgressRecipeIndex]
          : recipe.doneSteps;
    } else {
      _steps = recipe.cookingSteps
          .map((step) => {"step": step, "completed": false})
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) => buildRecipesRequestDetailsPage(context);

  void _onRecipesRequestDashboardListen(DashboardState dashboardState) {
    if (dashboardState is RecipeDetailsLoaded && _recipe == null) {
      setState(() => _initRecipe(dashboardState.recipeEntity));
    }
    if (dashboardState is DashboardFailure) {
      AppToast.show(dashboardState.message, ToastType.error);
    }
  }

  void _handleCancelRecipe(DashboardState state) {
    if (state is RecipeDetailsLoaded) {
      inProgressRecipeId = state.recipeEntity.id.isNotEmpty
          ? state.recipeEntity.id
          : state.recipeEntity.recipeId;
      inProgressRecipeIndex = _plannerBloc.state.startedRecipe.indexWhere(
        (r) =>
            r.recipeId == inProgressRecipeId ||
            (r.recipeId.isEmpty && r.id == inProgressRecipeId),
      );

      _plannerBloc.add(
        CancelInProgressRecipeEvent(
          inProgressRecipeIndex: inProgressRecipeIndex,
        ),
      );
      setState(() => _steps.forEach((step) => step['completed'] = false));
    }
  }

  void _onRequestDetailsFavoritePressed(RecipeEntity recipe) {
    setState(() => _isFav = !_isFav);
    _plannerBloc.add(
      _isFav
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

  void _setRequestDetailsTab(int index) {
    setState(() => _selectedTab = index);
  }

  Future<void> _handleStartOrRequestRecipe(
    BuildContext context,
    PlannerState state,
    RecipeEntity recipe,
  ) async {
    if (context.read<UserCubit>().state.role == "member") {
      devLog("recipe-recipeId: ${recipe.recipeId} - recipe-id: ${recipe.id}");
      _plannerBloc.add(
        RequestStartRecipeEvent(
          recipeId: recipe.id,
          kitchenId: context.read<UserCubit>().state.activeKitchenId,
          recipeName: recipe.title,
        ),
      );
    } else {
      _plannerBloc.add(
        UpdateStartRecipeEvent(
          startRecipe: true,
          recipeEntity: [...state.startedRecipe, recipe as RecipeModel],
          doneSteps: _steps,
        ),
      );
      setState(() => _selectedTab = 1);
    }
  }

  Future<void> _handleStepToggle(int index, bool isCompleted) async {
    final startRecipe = _plannerBloc.state.startedRecipe.any(
      (recipe) =>
          recipe.recipeId == inProgressRecipeId ||
          (recipe.recipeId.isEmpty && recipe.id == inProgressRecipeId),
    );

    if (!startRecipe) {
      AppToast.show(
        "Start the recipe first before proceeding to the steps!",
        ToastType.warning,
      );
      return;
    }

    if (isCompleted) {
      final uncheck = await showRecipesRequestUncheckStepDialog(context);
      if (uncheck == true) {
        setState(() => _steps[index]["completed"] = false);
      }
    } else {
      setState(() => _steps[index]["completed"] = true);
      if (_steps.every(
        (Map<String, dynamic> step) => readJsonBool(step, 'completed'),
      )) {
        CompleteDialogWidget.show(
          context,
          onFinish: () {
            _plannerBloc.add(
              MarkRecipeFinishedEvent(
                kitchenId: context.read<UserCubit>().state.activeKitchenId,
                recipeId: _recipe!.id,
              ),
            );
          },
        );
      }
    }
  }

  void _clearRequestDetailsStepsCompleted() {
    setState(() => _steps.forEach((step) => step["completed"] = false));
  }

  Future<void> _completeRecipeStartRequestForHostSideEffect() async {
    await _completeRecipeStartRequestForHost(
      CompleteRecipeStartRequestForHostParams(
        hostUserId: context.read<UserCubit>().state.userId,
        recipeId: widget.recipeId,
      ),
    );
  }
}
