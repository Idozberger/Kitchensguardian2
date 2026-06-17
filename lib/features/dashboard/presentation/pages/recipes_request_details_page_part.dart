// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls

part of 'package:foodkitchen/features/dashboard/presentation/pages/recipes_request_details_page.dart';

extension _RecipesRequestDetailsPageWidgets on _RecipesRequestDetailsPageState {
  Widget buildRecipesRequestDetailsContent(
    BuildContext context,
    PlannerState state,
  ) {
    final recipe = _recipe!;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          spacing: h(14),
          children: [
            buildRecipesRequestDetailsHeader(recipe),
            RecipeInfoWidget(recipe: recipe, isRequestedRecipe: true),
            (context.read<UserCubit>().state.role == "member")
                ? SizedBox()
                : buildRecipesRequestDetailsPrimaryActions(
                    context,
                    state,
                    recipe,
                    true,
                    context.read<DashboardBloc>(),
                  ),
            buildRecipesRequestDetailsTabs(),
            buildRecipesRequestDetailsTabContent(state, recipe),
            gap(height: 18),
          ],
        ),
      ),
    );
  }

  Widget buildRecipesRequestDetailsHeader(RecipeEntity recipe) {
    return HeaderImageWidget(
      isFavorite: _isFav,
      onFavoritePressed: () => _onRequestDetailsFavoritePressed(recipe),
      thumbnailBytes: recipe.thumbnail,
    );
  }

  Widget buildRecipesRequestDetailsPrimaryActions(
    BuildContext context,
    PlannerState state,
    RecipeEntity recipe,
    bool isRequestedRecipe,
    DashboardBloc dashboardBloc,
  ) {
    final isInProgress = state.startedRecipe.any(
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
      onStartOrRequestRecipe: () =>
          _handleStartOrRequestRecipe(context, state, recipe),
      onCancel: () {
        _handleCancelRecipe(dashboardBloc.state);
      },
      onFinish: () =>
          showRecipesRequestDetailsFinishDialog(context, state, recipe),
    );
  }

  Widget buildRecipesRequestDetailsTabs() {
    return SecondaryActionsWidget(
      selectedIndex: _selectedTab,
      onTabSelected: _setRequestDetailsTab,
    );
  }

  Widget buildRecipesRequestDetailsTabContent(
    PlannerState state,
    RecipeEntity recipe,
  ) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: _selectedTab == 0
          ? buildRecipesRequestDetailsIngredientsTab(recipe)
          : buildRecipesRequestDetailsStepsTab(state, recipe),
    );
  }

  Widget buildRecipesRequestDetailsIngredientsTab(RecipeEntity recipe) {
    return Column(
      children: [
        IngredientsListWidget(recipe: recipe),
        gap(height: 16),
      ],
    );
  }

  Widget buildRecipesRequestDetailsStepsTab(
    PlannerState state,
    RecipeEntity recipe,
  ) {
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

  Widget buildRecipesRequestDetailsPage(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        widget.backPageAvailable ? context.pop() : context.go(Routes.dashboard);
      },
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (_, dashboardState) =>
            _onRecipesRequestDashboardListen(dashboardState),
        child: BlocConsumer<PlannerBloc, PlannerState>(
          listener: (_, state) {
            if (state.successMessage.isNotEmpty) {
              AppToast.show(state.successMessage, ToastType.success);
            }
            if (state.isRecipeFinished) {
              devLog("calling recipe start request complete");
              _completeRecipeStartRequestForHostSideEffect();
              context.pop();
              _handleCancelRecipe(context.read<DashboardBloc>().state);
            }
          },
          builder: (_, plannerState) {
            return Scaffold(
              backgroundColor: const Color(0xffF9F9F9),
              appBar: AppBarWidget(
                onNavigatorback: () {
                  devLog("backpress: ${widget.backPageAvailable}");
                  widget.backPageAvailable
                      ? context.pop()
                      : context.go(Routes.dashboard);
                },
              ),
              body: _recipe == null
                  ? RecipesRequestDetailsLoadingView(
                      recipeId: widget.recipeId,
                      kitchenId: widget.kitchenId,
                    )
                  : buildRecipesRequestDetailsContent(context, plannerState),
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

  Future<void> showRecipesRequestDetailsFinishDialog(
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
        _clearRequestDetailsStepsCompleted();
      },
      onSecondaryPressed: () => context.pop(),
    );
  }
}
