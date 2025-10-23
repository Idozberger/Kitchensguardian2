import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';

import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class PrimaryActionsWidget extends StatelessWidget {
  final MealTypeEntity recipe;
  final bool isPlan;
  final bool startRecipe;
  final VoidCallback onStartRecipe;
  final VoidCallback onFinishOrCancel;
  final VoidCallback addToWeeklyPlanCallback;

  const PrimaryActionsWidget({
    super.key,
    required this.recipe,
    required this.isPlan,
    required this.startRecipe,
    required this.onStartRecipe,
    required this.addToWeeklyPlanCallback,
    required this.onFinishOrCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return Column(
            children: [
              startRecipe
                  ? Row(
                      children: [
                        Flexible(
                          child: GenericButtonWidget(
                            onPressed: onFinishOrCancel,
                            text: "Finish Recipe",
                            backgroundColor: Colors.white,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: w(12)),
                        Flexible(
                          child: GenericButtonWidget(
                            onPressed: onFinishOrCancel,
                            text: "Cancel Recipe",
                            backgroundColor: Colors.white,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  : GenericButtonWidget(
                      isDisabled: recipe.missingItems,
                      onPressed: () {
                        if (recipe.missingItems == false) {
                          onStartRecipe();
                        } else {
                          AppToast.show(
                            "Some ingredients are missing, so the recipe can't be started.",
                            ToastType.error,
                          );
                        }
                      },
                      text: "Start Recipe",
                    ),
              if (isPlan) ...[
                gap(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: h(40),
                  child: OutlinedButton(
                    onPressed: () {
                      addToWeeklyPlanCallback();
                    },
                    child: state.addingToWeeklyPlan
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Text(
                            "Add to Weekly Meal Plan",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: t(14),
                                  color: AppColors.primaryColor,
                                ),
                          ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
