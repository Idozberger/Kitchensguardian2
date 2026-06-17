part of 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/pages/add_meal_page.dart';

extension _AddMealPageWidgets on _AddMealPageState {
  Widget buildAddMealMainContent(PlannerState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: gapSymmetric(
          horizontal: _AddMealPageState._defaultPadding,
          vertical: _AddMealPageState._defaultPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildAddMealDateSelector(state),
            gap(height: _AddMealPageState._gapBetweenSections),
            buildAddMealMealTypeSelector(state),
            buildAddMealGenerateRecipeButton(state),
            buildAddMealMealPlanContent(state),
          ],
        ),
      ),
    );
  }

  Widget buildAddMealLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  AppBar buildAddMealAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(_AddMealPageState._appBarLeadingWidth),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => _handleBackNavigation(context),
          ),
        ],
      ),
      centerTitle: true,
      title: Text(
        "Add New Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget buildAddMealDateSelector(PlannerState state) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, currentState) {
        return SelectDateWidget(
          selectedDate: currentState.selectedDate,
          startDate: _startDate,
          hasPremiumAccess: context.read<UserCubit>().state.hasPremiumAccess,
          onChanged: (selected) => _handleDateSelection(currentState, selected),
        );
      },
    );
  }

  Widget buildAddMealMealTypeSelector(PlannerState state) {
    return MealTypeSelector(
      selectedIndex: state.mealTypeSelectedIndex,
      onSelected: (index) =>
          _plannerBloc.add(UpdateTypeSelectedAndDateEvent(index: index)),
    );
  }

  Widget buildAddMealGenerateRecipeButton(PlannerState state) {
    if (!_addMealShouldShowGenerateButton(state)) {
      return const SizedBox();
    }

    final formattedDate = DateFormat(
      _AddMealPageState._dateFormat,
    ).format(state.selectedDate ?? DateTime.now());

    return Padding(
      padding: gapOnly(top: _AddMealPageState._gapBetweenSections),
      child: GenericButtonWidget(
        text: "Generate Recipe",
        onPressed: () =>
            _addMealNavigateToGenerateRecipes(formattedDate, state),
      ),
    );
  }

  bool _addMealShouldShowGenerateButton(PlannerState state) {
    if (state.mealPlans.isEmpty) {
      return true;
    }

    final plan = state.mealPlans.first;
    final selectedMealIndex = state.mealTypeSelectedIndex;

    if (selectedMealIndex == 0) return plan.breakfast == null;
    if (selectedMealIndex == 1) return plan.lunch == null;
    if (selectedMealIndex == 2) return plan.dinner == null;

    return false;
  }

  void _addMealNavigateToGenerateRecipes(
    String formattedDate,
    PlannerState state,
  ) {
    context.pushNamed(
      Routes.generateRecipes,
      extra: {
        "selected_date": formattedDate,
        "selected_meal_type":
            _AddMealPageState._mealTypes[state.mealTypeSelectedIndex],
        "is_plan": true,
        "is_edit": false,
      },
    );
  }

  Widget buildAddMealMealPlanContent(PlannerState state) {
    if (state.mealPlans.isEmpty) {
      return const SizedBox();
    }

    final plan = state.mealPlans.first;
    final formattedDate = formatDate(state.selectedDate!);
    final isMatchingDate = plan.date == formattedDate;

    if (!isMatchingDate) {
      return const SizedBox();
    }

    return Column(
      children: [
        GeneratedRecipeSection(
          isEdit: false,
          date: formattedDate,
          mealPlan: plan,
          selectedIndex: state.mealTypeSelectedIndex,
        ),
        gap(height: _AddMealPageState._gapBetweenMealPlanSections),
        MealActionRow(
          selectedIndex: state.mealTypeSelectedIndex,
          plan: plan,
          callback: () => _handleBackNavigation(context),
        ),
      ],
    );
  }
}
