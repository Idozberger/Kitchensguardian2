import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_content.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_date_formatter.dart';
import 'package:go_router/go_router.dart';

class PlannerController {
  final PlannerBloc plannerBloc;
  final UserCubit userCubit;

  PlannerController({required this.plannerBloc, required this.userCubit});

  void initialize() {
    if (userCubit.state.activeKitchenId.isEmpty) return;
    plannerBloc.add(
      GetDateRangeEvent(kitchenId: userCubit.state.activeKitchenId),
    );
  }

  void handleStateChanges(BuildContext context, PlannerState state) {
    if (state.successMessage.isNotEmpty) {
      AppToast.show(state.successMessage, ToastType.success);
    }
    if (state.errorMessage?.isNotEmpty ?? false) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }
  }

  void onDateSelected(DateTime date) {
    plannerBloc.add(
      GetDateBasedPlans(PlannerDateFormatter.toBackendFormat(date)),
    );
  }

  void onAddMealPressed(BuildContext context, PlannerState state) {
    plannerBloc.add(ResetMealPlanState());
    final date = _getEffectiveDate(state);
    plannerBloc.add(UpdateTypeSelectedAndDateEvent(date: date, index: 0));
    context.push(Routes.addMeal);
  }

  void onEditPlan(BuildContext context, MergedRecipePlanEntity plan) {
    plannerBloc.add(ResetMealPlanState());

    _addMealsToBloc(plan);

    plannerBloc.add(
      UpdateTypeSelectedAndDateEvent(
        index: 0,
        date: PlannerDateFormatter.parseBackendDate(plan.date),
      ),
    );
    context.push(Routes.editMeal);
  }

  void onDeletePlan(BuildContext context, MergedRecipePlanEntity plan) {
    PlannerDialogs.showDeleteConfirmation(
      context: context,
      onConfirm: () {
        plannerBloc.add(
          DeletePlanFromRemoteDbEvent(
            mealPlanId: plan.breakfast?.mealplanId ?? "",
            date: plan.date,
            kitchenId: userCubit.state.activeKitchenId,
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  void onAddToCart(BuildContext context) {
    if (AppConstants.entitlementIsActive) {
      AppToast.show("Added to cart", ToastType.success);
    } else {
      AppToast.show("Only premium users can add to cart", ToastType.error);
    }
  }

  DateTime _getEffectiveDate(PlannerState state) {
    if (state.startDate?.isNotEmpty ?? false) {
      return PlannerDateFormatter.parseBackendDate(state.startDate!);
    }
    return DateTime.now();
  }

  void _addMealsToBloc(MergedRecipePlanEntity plan) {
    final meals = [plan.breakfast, plan.lunch, plan.dinner];
    for (final meal in meals) {
      if (meal != null) {
        plannerBloc.add(
          AddMealPlanEvent(
            date: plan.date,
            kitchenId: userCubit.state.activeKitchenId,
            mealPlan: meal as RecipeModel,
          ),
        );
      }
    }
  }

  void dispose() {}
}
