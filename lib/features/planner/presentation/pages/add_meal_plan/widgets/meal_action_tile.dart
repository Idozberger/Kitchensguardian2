import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:go_router/go_router.dart';

class MealActionRow extends StatelessWidget {
  final int selectedIndex;

  final MergedMealPlanEntity plan;

  const MealActionRow({
    super.key,
    required this.selectedIndex,
    required this.plan,
  });

  bool get _hasMeal {
    if (selectedIndex == 0) return plan.breakfast != null;
    if (selectedIndex == 1) return plan.lunch != null;
    return plan.dinner != null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasMeal) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go(Routes.dashboard),
            child: Text(
              "Cancel",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        gap(width: 12),
        Expanded(
          child: GenericButtonWidget(
            text: "Add Meal",
            onPressed: () {
              final plannerBloc = context.read<PlannerBloc>();

              if (plan.breakfast != null) {
                plannerBloc.add(AddToWeeklyPlanEvent(plan.breakfast!));
              }
              if (plan.lunch != null) {
                plannerBloc.add(AddToWeeklyPlanEvent(plan.lunch!));
              }
              if (plan.dinner != null) {
                plannerBloc.add(AddToWeeklyPlanEvent(plan.dinner!));
              }

              context.go(Routes.dashboard);
            },
          ),
        ),
      ],
    );
  }
}
