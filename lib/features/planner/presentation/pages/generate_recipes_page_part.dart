// ignore_for_file: prefer_final_fields, use_build_context_synchronously

part of 'package:foodkitchen/features/planner/presentation/pages/generate_recipes_page.dart';

extension _GenerateRecipesPageWidgets on _GenerateRecipesPageState {
  Widget buildGenerateRecipesBody(PlannerState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: gapSymmetric(horizontal: 20, vertical: 14),
        child: Column(
          children: [
            if (state.startedRecipe.isNotEmpty)
              buildRecipeInProgressNotification(state),
            buildGenerateRecipesSearchBar(),
            if (state.isLoading || state.isFavLoading)
              buildGenerateRecipesLoadingState()
            else ...[
              if (state.recipes != null && state.recipes!.isNotEmpty)
                gap(height: 14),
              buildGeneratedRecipesSection(state),
              gap(height: 14),
              buildSavedRecipesSection(state),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildRecipeInProgressNotification(PlannerState state) {
    return Column(
      children: state.startedRecipe.map((recipe) {
        return RecipeInProgressNotification(
          onCancelRecipe: () {
            _plannerBloc.add(
              UpdateStartRecipeEvent(
                startRecipe: false,
                recipeEntity: [],
                doneSteps: [],
              ),
            );
          },
          padding: gapOnly(bottom: 14),
          canCancel: true,
          recipeEntity: recipe,
        );
      }).toList(),
    );
  }

  Widget buildGenerateRecipesSearchBar() {
    return SearchBarWidgetForGenerateRecipes(
      controller: _searchController,
      onSearchTap: _generateRecipes,
    );
  }

  Widget buildGenerateRecipesLoadingState() {
    return Padding(
      padding: gapOnly(top: 100),
      child: Lottie.asset(AppAssets.loader),
    );
  }

  Widget buildGeneratedRecipesSection(PlannerState state) {
    return GeneratedRecipesSection(
      state: state,
      selectedDate: widget.selectedDate,
      selectedMealType: widget.selectedMealType,
      isPlan: widget.isPlan,
      isEdit: widget.isEdit,
    );
  }

  Widget buildSavedRecipesSection(PlannerState state) {
    return SavedRecipesSection(
      state: state,
      selectedDate: widget.selectedDate,
      selectedMealType: widget.selectedMealType,
      isPlan: widget.isPlan,
      isEdit: widget.isEdit,
    );
  }

  AppBar buildGenerateRecipesAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: buildGenerateRecipesBackButton(),
      actions: [buildGenerateRecipesFilterButton(), gap(width: 20)],
      title: Text(
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget buildGenerateRecipesBackButton() {
    return Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => context.pop(),
        ),
      ],
    );
  }

  Widget buildGenerateRecipesFilterButton() {
    return CircularIconButton(
      iconAsset: AppAssets.filterSvg,
      onTap: showGenerateRecipesFilterBottomSheet,
    );
  }

  void showGenerateRecipesFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.4),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: AddFilterBottomSheet(
            controller: _caloriesFilter,
            sliderValue: _sliderValue,
            hoursController: _hoursController,
            minController: _minController,
            onChanged: _updateTimeFormatters,
            callback: handleGenerateRecipesFilterApplied,
          ),
        ),
      ),
    );
  }

  void handleGenerateRecipesFilterApplied() {
    final text = _caloriesFilter.text.trim();
    if (text.isEmpty) {
      AppToast.show(
        "Please enter a filter value before adding.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
    } else {
      AppToast.show("Filter applied", ToastType.success);
      context.pop();
    }
  }
}
