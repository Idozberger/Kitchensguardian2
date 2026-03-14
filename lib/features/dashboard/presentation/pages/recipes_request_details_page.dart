// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls, duplicate_ignore

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
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
import 'package:lottie/lottie.dart';

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

  @override
  void initState() {
    super.initState();
    _plannerBloc = context.read<PlannerBloc>();
    _dashboardBloc = context.read<DashboardBloc>();

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

  Future<void> updateRecipeStatus() async {
    log("calling recipe start requst");
    final querySnapshot = await FirebaseFirestore.instance
        .collection('recipe_start_requests')
        .where(
          'host_user_id',
          isEqualTo: context.read<UserCubit>().state.userId,
        )
        .where('recipe_id', isEqualTo: widget.recipeId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({
        'recipe_status': 'Completed',

        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        widget.backPageAvailable ? context.pop() : context.go(Routes.dashboard);
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, dashboardState) {
          if (dashboardState is RecipeDetailsLoaded && _recipe == null) {
            setState(() => _initRecipe(dashboardState.recipeEntity));
          }
          if (dashboardState is DashboardFailure) {
            AppToast.show(dashboardState.message, ToastType.error);
          }
        },
        child: BlocConsumer<PlannerBloc, PlannerState>(
          listener: (_, state) {
            if (state.successMessage.isNotEmpty) {
              AppToast.show(state.successMessage, ToastType.success);
            }
            if (state.isRecipeFinished) {
              updateRecipeStatus();
              context.pop();
              _handleCancelRecipe(context.read<DashboardBloc>().state);
            }
          },
          builder: (_, plannerState) {
            return Scaffold(
              backgroundColor: const Color(0xffF9F9F9),
              appBar: AppBarWidget(
                onNavigatorback: () {
                  log("backpress: ${widget.backPageAvailable}");
                  widget.backPageAvailable
                      ? context.pop()
                      : context.go(Routes.dashboard);
                },
              ),
              body: _recipe == null
                  ? _buildLoading()
                  : _buildContent(context, plannerState),
              bottomNavigationBar: _recipe == null
                  ? null
                  : BlocBuilder<PlannerBloc, PlannerState>(
                      builder: (_, state) {
                        return state.startedRecipe.any(
                                  (recipe) =>
                                      recipe.recipeId == inProgressRecipeId ||
                                      (recipe.recipeId.isEmpty &&
                                          recipe.id == inProgressRecipeId),
                                ) &&
                                _selectedTab == 1
                            ? BottomNavRecipeDetails(steps: _steps)
                            : const SizedBox.shrink();
                      },
                    ),
            );
          },
        ),
      ),
    );
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
      // ignore: avoid_function_literals_in_foreach_calls
      setState(() => _steps.forEach((step) => step['completed'] = false));
    }
  }

  Widget _buildLoading() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (_, state) {
        if (state is DashboardFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _dashboardBloc.add(
                    GetRecipeDetailsEvent(
                      recipeId: widget.recipeId,
                      kitchenId: widget.kitchenId,
                    ),
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return Center(child: Lottie.asset("assets/lotties/loader.json"));
      },
    );
  }

  Widget _buildContent(BuildContext context, PlannerState state) {
    final recipe = _recipe!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          spacing: h(14),
          children: [
            _buildHeader(recipe),
            RecipeInfoWidget(recipe: recipe, isRequestedRecipe: true),
            (context.read<UserCubit>().state.role == "member")
                ? SizedBox()
                : _buildPrimaryActions(
                    context,
                    state,
                    recipe,
                    true,
                    context.read<DashboardBloc>(),
                  ),
            _buildTabs(),
            _buildTabContent(state, recipe),
            gap(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RecipeEntity recipe) {
    return HeaderImageWidget(
      isFavorite: _isFav,
      onFavoritePressed: () {
        setState(() => _isFav = !_isFav);
        _plannerBloc.add(
          _isFav
              ? AddToFavouriteRecipeEvent(recipe.id)
              : RemoveFromFavouriteRecipeEvent(recipe.id),
        );
      },
      thumbnailBytes: recipe.thumbnail,
    );
  }

  Widget _buildPrimaryActions(
    BuildContext context,
    PlannerState state,
    RecipeEntity recipe,
    bool isRequestedRecipe,
    DashboardBloc dashboardBloc,
  ) {
    bool isInProgress = state.startedRecipe.any(
      (r) => r.id == inProgressRecipeId,
    );

    return PrimaryActionsWidget(
      isRequestedRecipe: isRequestedRecipe,
      completed: widget.isCompleted == "Completed",
      canRequestToStartRecipe: false,
      addPlanDummyLoading: false,
      recipe: recipe,
      isPlan: false,
      startRecipe: isInProgress,
      isFinishing: state.isFinishingRecipe,
      addToWeeklyPlanCallback: () {},
      onStartOrRequestRecipe: () async {
        if (context.read<UserCubit>().state.role == "member") {
          log("recipe-recipeId: ${recipe.recipeId} - recipe-id: ${recipe.id}");
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
      },
      onCancel: () {
        _handleCancelRecipe(dashboardBloc.state);
      },
      onFinish: () => _showFinishConfirmationDialog(context, state, recipe),
    );
  }

  Widget _buildTabs() {
    return SecondaryActionsWidget(
      selectedIndex: _selectedTab,
      onTabSelected: (index) => setState(() => _selectedTab = index),
    );
  }

  Widget _buildTabContent(PlannerState state, RecipeEntity recipe) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: _selectedTab == 0
          ? _buildIngredientsTab(recipe)
          : _buildStepsTab(state, recipe),
    );
  }

  Widget _buildIngredientsTab(RecipeEntity recipe) {
    return Column(
      children: [
        IngredientsListWidget(recipe: recipe),
        gap(height: 16),
      ],
    );
  }

  Widget _buildStepsTab(PlannerState state, RecipeEntity recipe) {
    return Column(
      children: [
        RecipeSummaryTile(recipe: recipe),
        gap(height: 15),
        RecipeStepsTile(
          recipe: recipe,
          steps: _steps,
          onStepToggle: _handleStepToggle,
        ),
      ],
    );
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
      final uncheck = await _confirmUncheckDialog();
      if (uncheck == true) {
        setState(() => _steps[index]["completed"] = false);
      }
    } else {
      setState(() => _steps[index]["completed"] = true);
      if (_steps.every((step) => step["completed"])) {
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

  Future<bool?> _confirmUncheckDialog() {
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

  Future<void> _showFinishConfirmationDialog(
    BuildContext context,
    PlannerState state,
    RecipeEntity recipe,
  ) {
    return showCustomGenericDialog(
      isloading: state.isFinishingRecipe,
      context: context,
      title: "Finish Recipe?",
      subtitle:
          "This will mark the recipe as completed and automatically remove all used ingredients from your kitchen inventory.",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        _plannerBloc.add(
          MarkRecipeFinishedEvent(
            kitchenId: context.read<UserCubit>().state.activeKitchenId,
            recipeId: recipe.id,
          ),
        );
        setState(() => _steps.forEach((step) => step["completed"] = false));
      },
      onSecondaryPressed: () => context.pop(),
    );
  }
}
