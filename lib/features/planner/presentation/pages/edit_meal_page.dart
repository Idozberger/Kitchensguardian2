import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/generated_recipe_section.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_action_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_type_selector.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditMealPage extends StatefulWidget {
  const EditMealPage({super.key});

  @override
  State<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late PlannerBloc plannerBloc;
  bool isLoading = true;
  late DateTime startDate;
  final mealTypes = const ["Breakfast", "Lunch", "Dinner"];

  @override
  void initState() {
    super.initState();
    plannerBloc = context.read<PlannerBloc>();
    _initializeDate();
  }

  Future<void> _initializeDate() async {
    setState(() => isLoading = true);

    final state = plannerBloc.state;

    if (state.mealPlans.isEmpty) {
      startDate = DateTime.now();
    } else {
      final List<DateTime> planDates = state.mealPlans
          .map((plan) {
            try {
              return DateTime.parse(plan.date);
            } catch (e) {
              return null;
            }
          })
          .whereType<DateTime>()
          .toList();

      if (planDates.isEmpty) {
        startDate = DateTime.now();
      } else {
        planDates.sort((a, b) => b.compareTo(a));

        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        final todayPlanDate = planDates.cast<DateTime?>().firstWhere(
          (date) =>
              date != null &&
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day,
          orElse: () => null,
        );

        if (todayPlanDate != null) {
          startDate = todayPlanDate;
        } else {
          startDate = planDates.first;
        }
      }
    }

    plannerBloc.add(
      UpdateTypeSelectedAndDateEvent(
        index: 0, // breakfast
        date: startDate,
      ),
    );

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
    super.build(context);
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (context, state) {
        if (state.successMessage.isNotEmpty) {
          AppToast.show(state.successMessage, ToastType.success);
          plannerBloc.add(UpdateTypeSelectedAndDateEvent(index: 0));
          context.read<PlannerBloc>().add(ResetMealPlanState());
          context.go(Routes.dashboard);
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.show(state.errorMessage!, ToastType.error);
        }
      },
      builder: (_, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, _) async =>
              _handleBackNavigation(context),
          child: Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: gapSymmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MealTypeSelector(
                            selectedIndex: state.mealTypeSelectedIndex,
                            onSelected: (index) => plannerBloc.add(
                              UpdateTypeSelectedAndDateEvent(index: index),
                            ),
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
        "Edit Meal",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildMealPlanContent(PlannerState state) {
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
        _buildEditMealRow(state, plan),
      ],
    );
  }

  Widget _buildEditMealRow(PlannerState state, MergedMealPlanEntity plan) {
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

  Widget _buildGenerateRecipeButton() {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        if (state.mealPlans.isEmpty) {
          return _buildGenerateButton(context, state);
        } else {
          final plan = state.mealPlans.first;
          if (state.mealTypeSelectedIndex == 0 && plan.breakfast == null) {
            return _buildGenerateButton(context, state);
          } else if (state.mealTypeSelectedIndex == 1 && plan.lunch == null) {
            return _buildGenerateButton(context, state);
          } else if (state.mealTypeSelectedIndex == 2 && plan.dinner == null) {
            return _buildGenerateButton(context, state);
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  Widget _buildGenerateButton(BuildContext context, PlannerState state) {
    final formatted = DateFormat(
      'dd/MM/yyyy',
    ).format(state.selectedDate ?? DateTime.now());

    return Padding(
      padding: gapOnly(top: 20),
      child: GenericButtonWidget(
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
