// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_function_literals_in_foreach_calls

part of 'package:foodkitchen/features/planner/presentation/pages/recipes_details/recipes_details_page.dart';

extension _RecipesDetailsPageWidgets on _RecipesDetailsPageState {
  Widget buildRecipesDetailsBottomNav(PlannerState state) {
    final showBottomNav =
        state.startedRecipe.any((r) => r.recipeId == inProgressRecipeId) &&
        selectedTab == 1;

    return showBottomNav
        ? BottomNavRecipeDetails(steps: steps)
        : const SizedBox.shrink();
  }

  Widget buildRecipesDetailsContent(BuildContext context, PlannerState state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          spacing: h(14),
          children: [
            buildRecipesDetailsHeader(),
            RecipeInfoWidget(recipe: recipe),
            buildRecipesDetailsPrimaryActions(context, state),
            buildRecipesDetailsTabs(),
            buildRecipesDetailsTabContent(state),
            gap(height: 18),
          ],
        ),
      ),
    );
  }

  Widget buildRecipesDetailsHeader() {
    return HeaderImageWidget(
      isFavorite: isFav,
      thumbnailBytes: recipe.thumbnail,
      onFavoritePressed: _toggleFavourite,
    );
  }

  Widget buildRecipesDetailsPrimaryActions(
    BuildContext context,
    PlannerState state,
  ) {
    return PrimaryActionsWidget(
      canRequestToStartRecipe: widget.isRequestToStartRecipe,
      addPlanDummyLoading: addPlanDummyLoading,
      recipe: recipe,
      isPlan: widget.isPlan,
      startRecipe: _isRecipeInProgress,
      isFinishing: state.isFinishingRecipe,
      addToWeeklyPlanCallback: () => _handleAddToWeeklyPlan(context, state),
      onStartOrRequestRecipe: () => _handleStartOrRequest(state),
      onCancel: _handleCancelRecipe,
      onFinish: () => showRecipesDetailsFinishDialog(context, state),
    );
  }

  Widget buildRecipesDetailsTabs() {
    return SecondaryActionsWidget(
      selectedIndex: selectedTab,
      onTabSelected: _setRecipesDetailsTab,
    );
  }

  Widget buildRecipesDetailsTabContent(PlannerState state) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: selectedTab == 0
          ? buildRecipesDetailsIngredientsTab()
          : selectedTab == 1
          ? buildRecipesDetailsStepsTab(state)
          : buildRecipesDetailsMissingIngredientsTab(),
    );
  }

  Widget buildRecipesDetailsIngredientsTab() {
    return Column(children: [IngredientsListWidget(recipe: recipe)]);
  }

  Widget buildRecipesDetailsMissingIngredientsTab() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        return MissingItemsListWidget(
          recipeId: recipe.id,
          isPlanned: widget.isPlan,
          id: recipe.recipeId,
        );
      },
    );
  }

  Widget buildRecipesDetailsStepsTab(PlannerState state) {
    return Column(
      children: [
        RecipeSummaryTile(recipe: recipe),
        gap(height: 15),
        RecipeStepsTile(
          recipe: recipe,
          steps: steps,
          onStepToggle: _handleStepToggle,
        ),
      ],
    );
  }

  Future<bool?> showRecipesDetailsUncheckStepDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => GenericDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Uncheck Step',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: t(14),
              ),
            ),
            gap(height: 12),
            Text(
              'Are you sure you want to mark this step as incomplete?',
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> showRecipesDetailsFinishDialog(
    BuildContext context,
    PlannerState state,
  ) {
    return showCustomGenericDialog(
      isloading: state.isFinishingRecipe,
      context: context,
      title: 'Finish Recipe?',
      subtitle:
          'This will mark the recipe as completed and automatically remove '
          'all used ingredients from your kitchen inventory.',
      primaryButtonText: 'Yes',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () {
        plannerBloc.add(
          MarkRecipeFinishedEvent(
            kitchenId: context.read<UserCubit>().state.activeKitchenId,
            recipeId: _activeRecipeId,
          ),
        );
        _clearRecipesDetailsStepsCompleted();
      },
      onSecondaryPressed: () => context.pop(),
    );
  }
}
