import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/generated_recipe_section.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_action_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_type_selector.dart';
import 'package:foodkitchen/features/planner/presentation/pages/edit_meal_page.dart';

import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  bool isLoading = true;
  int selectedIndex = 0;
  late DateTime dateTime;

  final mealTypes = const ["Breakfast", "Lunch", "Dinner"];

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  Future<void> _initializeDate() async {
    final prefs = await SharedPreferences.getInstance();
    final startDate = prefs.getString("start-date");
    dateTime = startDate != null ? parseDate(startDate) : DateTime.now();
    setState(() => isLoading = false);
  }

  void _handleBackNavigation(BuildContext context) {
    final hasPlans = context.read<PlannerBloc>().state.mealPlans.isNotEmpty;
    if (hasPlans) {
      _showConfirmDialog(
        context,
        title: "Go Back",
        subtitle:
            "If you go back, the meal data you just added will be removed. Continue?",
        onConfirm: () => WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(Routes.dashboard);
        }),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.dashboard);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, __) async =>
              _handleBackNavigation(context),
          child: Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: gapSymmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateSelector(context),
                          gap(height: 20),
                          MealTypeSelector(
                            selectedIndex: selectedIndex,
                            onSelected: (index) =>
                                setState(() => selectedIndex = index),
                          ),
                          _buildGenerateRecipeButton(),
                          _buildMealPlanContent(state),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
        "Add New Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        return SelectDateWidget(
          startDate: dateTime,
          entitlementIsActive: false,
          onChanged: (selected) {
            final hasPlans =
                state.mealPlans.isNotEmpty &&
                state.mealPlans.first.date != formatDate(selected);

            if (hasPlans) {
              _showConfirmDialog(
                context,
                title: "Change Date",
                subtitle:
                    "Changing the date will remove existing meal plans. Continue?",
                onConfirm: () {
                  dateTime = selected;
                  context.read<PlannerBloc>().add(ResetMealPlanState());
                  AppToast.show("Previous plans removed", ToastType.success);
                  context.pop();
                },
              );
            } else {
              setState(() => dateTime = selected);
            }
          },
        );
      },
    );
  }

  Widget _buildMealPlanContent(PlannerState state) {
    if (state.mealPlans.isEmpty) return const SizedBox();

    final plan = state.mealPlans.first;
    final formattedDate = formatDate(dateTime);

    final isMatchingDate = plan.date == formattedDate;

    if (!isMatchingDate) return const SizedBox();

    return Column(
      children: [
        GeneratedRecipeSection(
          date: formattedDate,
          mealPlan: plan,
          selectedIndex: selectedIndex,
        ),
        gap(height: 18),
        MealActionRow(selectedIndex: selectedIndex, plan: plan),
      ],
    );
  }

  Widget _buildGenerateRecipeButton() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        if (state.mealPlans.isEmpty) {
          return _buildGenerateButton(context);
        } else {
          final plan = state.mealPlans.first;
          if (selectedIndex == 0 && plan.breakfast == null) {
            return _buildGenerateButton(context);
          } else if (selectedIndex == 1 && plan.lunch == null) {
            return _buildGenerateButton(context);
          } else if (selectedIndex == 2 && plan.dinner == null) {
            return _buildGenerateButton(context);
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  Widget _buildGenerateButton(BuildContext context) {
    final formatted = DateFormat('dd/MM/yyyy').format(dateTime);

    return Padding(
      padding: gapOnly(top: 20),
      child: GenericButtonWidget(
        text: "Generate Recipe",
        onPressed: () {
          context.pushNamed(
            Routes.generateRecipes,
            extra: {
              "selected_date": formatted,
              "selected_meal_type": mealTypes[selectedIndex],
              "is_plan": true,
            },
          );
        },
      ),
    );
  }

  Future<void> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => context.pop(),
    );
  }
}
