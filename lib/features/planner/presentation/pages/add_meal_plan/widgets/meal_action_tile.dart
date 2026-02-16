import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:go_router/go_router.dart';

class MealActionRow extends StatelessWidget {
  static const String _defaultButtonText = "Add Meal";
  static const String _cancelButtonText = "Cancel";
  static const String _notesPlaceholder = "notes";
  static const double _buttonGap = 12;
  static const double _cancelButtonFontSize = 12;

  final int selectedIndex;
  final MergedRecipePlanEntity plan;
  final String buttonText;
  final VoidCallback? callback;

  const MealActionRow({
    super.key,
    required this.selectedIndex,
    required this.plan,
    this.callback,
    this.buttonText = _defaultButtonText,
  });

  bool get _hasMeal {
    switch (selectedIndex) {
      case 0:
        return plan.breakfast != null;
      case 1:
        return plan.lunch != null;
      case 2:
        return plan.dinner != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasMeal) {
      return const SizedBox();
    }

    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        return Row(
          children: [
            _buildCancelButton(context),
            gap(width: _buttonGap),
            _buildAddMealButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed:
            callback ??
            () => context.goNamed(
              Routes.dashboard,
              extra: {
                'fromNotification': false,
                'entryType': DashboardEntryType.normal,
              },
            ),
        child: Text(
          _cancelButtonText,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: t(_cancelButtonFontSize),
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildAddMealButton(BuildContext context, PlannerState state) {
    return Expanded(
      child: GenericButtonWidget(
        text: buttonText,
        isLoading: state.isLoading,
        onPressed: state.isLoading
            ? () {}
            : () async => _handleAddMealPressed(context, state),
      ),
    );
  }

  Future<void> _handleAddMealPressed(
    BuildContext context,
    PlannerState state,
  ) async {
    final plannerBloc = context.read<PlannerBloc>();
    final kitchenId = context.read<UserCubit>().state.activeKitchenId;

    final formattedDate = _getFormattedDate();
    final mealPlans = _buildMealPlans(kitchenId, formattedDate);

    if (mealPlans.isEmpty) {
      return;
    }

    plannerBloc.add(CreatePlanEvent(mealPlans: mealPlans));
  }

  String _getFormattedDate() {
    String formattedDate = plan.date;

    if (!formattedDate.contains("-")) {
      formattedDate = formatDateForBackend(formattedDate);
    }

    log("DATE: $formattedDate");
    return formattedDate;
  }

  List<MealPlanEntity> _buildMealPlans(String kitchenId, String formattedDate) {
    final mealPlans = <MealPlanEntity>[];

    if (_shouldAddBreakfast()) {
      mealPlans.add(
        _createMealPlanEntity(
          kitchenId: kitchenId,
          date: formattedDate,
          mealType: "breakfast",
          recipeId: plan.breakfast!.id,
        ),
      );
    }

    if (_shouldAddLunch()) {
      mealPlans.add(
        _createMealPlanEntity(
          kitchenId: kitchenId,
          date: formattedDate,
          mealType: "lunch",
          recipeId: plan.lunch!.id,
        ),
      );
    }

    if (_shouldAddDinner()) {
      mealPlans.add(
        _createMealPlanEntity(
          kitchenId: kitchenId,
          date: formattedDate,
          mealType: "dinner",
          recipeId: plan.dinner!.id,
        ),
      );
    }

    return mealPlans;
  }

  bool _shouldAddBreakfast() {
    return plan.breakfast != null && plan.breakfast!.mealplanId.isEmpty;
  }

  bool _shouldAddLunch() {
    return plan.lunch != null && plan.lunch!.mealplanId.isEmpty;
  }

  bool _shouldAddDinner() {
    return plan.dinner != null && plan.dinner!.mealplanId.isEmpty;
  }

  MealPlanEntity _createMealPlanEntity({
    required String kitchenId,
    required String date,
    required String mealType,
    required String recipeId,
  }) {
    return MealPlanEntity(
      date: date,
      kitchenId: kitchenId,
      mealType: mealType,
      notes: _notesPlaceholder,
      recipeId: recipeId,
    );
  }

  String formatDateForBackend(String inputDate) {
    final parts = inputDate.split("/");

    if (parts.length != 3) {
      log("Invalid date format: $inputDate");
      return inputDate;
    }

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];

    return "$year-$month-$day";
  }
}
