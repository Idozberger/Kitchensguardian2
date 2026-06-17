part of 'package:foodkitchen/features/planner/presentation/pages/edit_meal_page.dart';

extension _EditMealPageWidgets on _EditMealPageState {
  AppBar buildEditMealAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              _handleBackNavigation(context);
            },
          ),
        ],
      ),
      centerTitle: true,
      title: Text(
        "Edit Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget buildEditMealMealPlanContent(PlannerState state) {
    if (state.mealPlans.isEmpty) return const SizedBox();

    final plan = state.mealPlans.first;
    final formattedDate = formatDateToMeetBackendDate(startDate);

    final isMatchingDate = plan.date == formattedDate;

    if (!isMatchingDate) return const SizedBox();

    return Column(
      children: [
        GeneratedRecipeSection(
          isEdit: true,
          date: formattedDate,
          mealPlan: plan,
          selectedIndex: state.mealTypeSelectedIndex,
        ),
        gap(height: 18),
        buildEditMealRow(state, plan),
      ],
    );
  }

  Widget buildEditMealRow(PlannerState state, MergedRecipePlanEntity plan) {
    if (state.mealTypeSelectedIndex == 0) {
      if (plan.breakfast == null || plan.breakfast!.mealplanId.isEmpty) {
        return MealActionRow(
          selectedIndex: state.mealTypeSelectedIndex,
          plan: plan,
          buttonText: "Edit Meal",
        );
      }
    } else if (state.mealTypeSelectedIndex == 1) {
      if (plan.lunch == null || plan.lunch!.mealplanId.isEmpty) {
        return MealActionRow(
          selectedIndex: state.mealTypeSelectedIndex,
          plan: plan,
          buttonText: "Edit Meal",
        );
      }
    } else if (state.mealTypeSelectedIndex == 2) {
      if (plan.dinner == null || plan.dinner!.mealplanId.isEmpty) {
        return MealActionRow(
          selectedIndex: state.mealTypeSelectedIndex,
          plan: plan,
          buttonText: "Edit Meal",
        );
      }
    }

    return const SizedBox();
  }

  Widget buildEditMealGenerateRecipeButton() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        if (state.mealPlans.isEmpty) {
          return buildEditMealGenerateButton(context, state);
        } else {
          final plan = state.mealPlans.first;
          if (state.mealTypeSelectedIndex == 0 && plan.breakfast == null) {
            return buildEditMealGenerateButton(context, state);
          } else if (state.mealTypeSelectedIndex == 1 && plan.lunch == null) {
            return buildEditMealGenerateButton(context, state);
          } else if (state.mealTypeSelectedIndex == 2 && plan.dinner == null) {
            return buildEditMealGenerateButton(context, state);
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  Widget buildEditMealGenerateButton(BuildContext context, PlannerState state) {
    final formatted = DateFormat(
      'dd/MM/yyyy',
    ).format(state.selectedDate ?? DateTime.now());

    return Padding(
      padding: gapOnly(top: 20),
      child: GenericButtonWidget(
        isLoading: isLoading,
        text: "Generate Recipe",
        onPressed: () {
          context.pushNamed(
            Routes.generateRecipes,
            extra: {
              "selected_date": formatted,
              "selected_meal_type": mealTypes[state.mealTypeSelectedIndex],
              "is_plan": true,
              "is_edit": true,
            },
          );
        },
      ),
    );
  }
}
