import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/controller/planner_controller.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class PlannerContent extends StatelessWidget {
  final PlannerState state;
  final PlannerController controller;

  const PlannerContent({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlannerHeader(
            onAddMeal: () => controller.onAddMealPressed(context, state),
          ),
          const SizedBox(height: 15),
          if (state.getAllWeeklyPlans.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: PlannerEmptyState(),
            )
          else
            PlannerList(state: state, controller: controller),
        ],
      ),
    );
  }
}

class PlannerHeader extends StatelessWidget {
  final VoidCallback onAddMeal;

  const PlannerHeader({super.key, required this.onAddMeal});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Plan your meals for the week ahead",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          GenericButtonWidget(onPressed: onAddMeal, text: "+ Add Meal"),
        ],
      ),
    );
  }
}

class PlannerList extends StatefulWidget {
  final PlannerState state;
  final PlannerController controller;

  const PlannerList({super.key, required this.state, required this.controller});

  @override
  State<PlannerList> createState() => _PlannerListState();
}

class _PlannerListState extends State<PlannerList> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = PlannerDateFormatter.getInitialDate(widget.state);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectDateWidget(
          entitlementIsActive: AppConstants.entitlementIsActive,
          startDate: PlannerDateFormatter.getStartDate(widget.state),
          selectedDate: _selectedDate,
          onChanged: (date) {
            setState(() => _selectedDate = date);
            widget.controller.onDateSelected(date);
          },
        ),
        const SizedBox(height: 15),
        _buildPlanForSelectedDate(),
      ],
    );
  }

  Widget _buildPlanForSelectedDate() {
    final plan = widget.state.dateBasedPlan;

    if (plan.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    final selectedDateStr = PlannerDateFormatter.toBackendFormat(
      _selectedDate!,
    );
    if (plan[0].date != selectedDateStr) {
      return const Padding(
        padding: EdgeInsets.only(top: 64),
        child: PlannerEmptyState(),
      );
    }

    return PlanCard(plan: plan[0], controller: widget.controller);
  }
}

class PlanCard extends StatelessWidget {
  final MergedRecipePlanEntity plan;
  final PlannerController controller;

  const PlanCard({super.key, required this.plan, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DayPlanTile(
        dayLabel: PlannerDateFormatter.toDisplayFormat(plan.date),
        meals: _buildMealsList(),
        viewRecipe: () =>
            context.pushNamed(Routes.viewPlanDetails, extra: plan),
        addToCart: () => controller.onAddToCart(context),
        deletePlan: () => controller.onDeletePlan(context, plan),
        editPlan: () => controller.onEditPlan(context, plan),
      ),
    );
  }

  List<MealTile> _buildMealsList() {
    return [
      if (plan.breakfast != null)
        MealTile(mealType: "Breakfast", mealName: plan.breakfast!.title),
      if (plan.lunch != null)
        MealTile(mealType: "Lunch", mealName: plan.lunch!.title),
      if (plan.dinner != null)
        MealTile(mealType: "Dinner", mealName: plan.dinner!.title),
    ];
  }
}

class PlannerEmptyState extends StatelessWidget {
  const PlannerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        context,
        imagePath: AppAssets.noKitchenFound,
        title: 'No meal found here',
      ),
    );
  }
}

class PlannerLoadingView extends StatelessWidget {
  const PlannerLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: Center(child: Lottie.asset(AppAssets.loader)),
    );
  }
}

class PlannerDateFormatter {
  static String toDisplayFormat(String backendDate) {
    final date = DateTime.parse(backendDate);
    return DateFormat('EEEE dd, yyyy').format(date);
  }

  static String toBackendFormat(DateTime date) {
    return formatDateToMeetBackendDate(date);
  }

  static DateTime parseBackendDate(String backendDate) {
    return formatStringDateToMeetBackendDate(backendDate);
  }

  static DateTime getInitialDate(PlannerState state) {
    if (state.startDate?.isNotEmpty ?? false) {
      try {
        return parseBackendDate(state.startDate!);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime getStartDate(PlannerState state) {
    final dateStr = (state.startDate?.isEmpty ?? true)
        ? toBackendFormat(DateTime.now())
        : state.startDate!;
    return parseBackendDate(dateStr);
  }
}

class PlannerDialogs {
  static Future<void> showDeleteConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }
}
