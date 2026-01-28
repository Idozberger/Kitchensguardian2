import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/controller/planner_controller.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_date_formatter.dart';
import 'package:go_router/go_router.dart';

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
