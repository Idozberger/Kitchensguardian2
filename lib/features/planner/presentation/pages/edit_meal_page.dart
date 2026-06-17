import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/navigation/router_navigation.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/generated_recipe_section.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_action_tile.dart';
import 'package:foodkitchen/features/planner/presentation/pages/add_meal_plan/widgets/meal_type_selector.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'edit_meal_page_part.dart';

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

    setState(() => isLoading = false);
  }

  void _navigateToDashboard() {
    goNamedAfterFrame(
      name: Routes.dashboard,
      extra: {
        'fromNotification': false,
        'entryType': DashboardEntryType.normal,
      },
      isPageMounted: () => mounted,
      pageContext: () => context,
    );
  }

  void _handleBackNavigation(BuildContext context) {
    final hasPlans = context.read<PlannerBloc>().state.mealPlans.isNotEmpty;
    if (hasPlans) {
      _showConfirmDialog(
        context,
        title: "Go Back",
        subtitle:
            "If you go back, the meal data you just added will be removed. Continue?",
        onConfirm: _navigateToDashboard,
      );
    } else {
      _navigateToDashboard();
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
          _navigateToDashboard();
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          AppToast.show(state.errorMessage!, ToastType.error);
        }
      },
      builder: (_, state) {
        devLog("meal type index: ${state.mealTypeSelectedIndex}");
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (_, _) async =>
              _handleBackNavigation(context),
          child: Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: buildEditMealAppBar(context),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: gapSymmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<PlannerBloc, PlannerState>(
                            builder: (context, state) {
                              return MealTypeSelector(
                                selectedIndex: state.mealTypeSelectedIndex,
                                onSelected: (index) => plannerBloc.add(
                                  UpdateTypeSelectedAndDateEvent(index: index),
                                ),
                              );
                            },
                          ),
                          buildEditMealGenerateRecipeButton(),
                          buildEditMealMealPlanContent(state),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
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
