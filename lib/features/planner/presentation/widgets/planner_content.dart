import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/controller/planner_controller.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_empty_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_header.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/planner_list.dart';

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

extension FirstWhereOrNullExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
