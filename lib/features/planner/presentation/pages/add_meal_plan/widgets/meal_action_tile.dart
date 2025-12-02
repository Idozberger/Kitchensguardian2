import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:go_router/go_router.dart';

class MealActionRow extends StatelessWidget {
  final int selectedIndex;
  final MergedRecipePlanEntity plan;
  final String buttonText;
  final VoidCallback? callback;

  const MealActionRow({
    super.key,
    required this.selectedIndex,
    required this.plan,
    this.callback,
    this.buttonText = "Add Meal",
  });

  bool get _hasMeal {
    if (selectedIndex == 0) return plan.breakfast != null;
    if (selectedIndex == 1) return plan.lunch != null;
    return plan.dinner != null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasMeal) return const SizedBox();

    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: callback ?? () => context.go(Routes.dashboard),
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
                text: buttonText,
                isLoading: state.isLoading,
                onPressed: state.isLoading
                    ? () {}
                    : () async {
                        final plannerBloc = context.read<PlannerBloc>();
                        final kitchenId = context
                            .read<UserCubit>()
                            .state
                            .activeKitchenId;
                        log("DATE: ${plan.date}");
                        String formattedDate = plan.date;
                        if (!formattedDate.contains("-")) {
                          formattedDate = formatDateForBackend(plan.date);
                        }

                        final List<MealPlanEntity> mealPlans = [];

                        if (plan.breakfast != null) {
                          if (plan.breakfast!.mealplanId.isEmpty) {
                            mealPlans.add(
                              MealPlanEntity(
                                date: formattedDate,
                                kitchenId: kitchenId,
                                mealType: "breakfast",
                                notes: "notes",
                                recipeId: plan.breakfast!.id,
                              ),
                            );
                          }
                        }

                        if (plan.lunch != null) {
                          if (plan.lunch!.mealplanId.isEmpty) {
                            mealPlans.add(
                              MealPlanEntity(
                                date: formattedDate,
                                kitchenId: kitchenId,
                                mealType: "lunch",
                                notes: "notes",
                                recipeId: plan.lunch!.id,
                              ),
                            );
                          }
                        }

                        if (plan.dinner != null) {
                          if (plan.dinner!.mealplanId.isEmpty) {
                            mealPlans.add(
                              MealPlanEntity(
                                date: formattedDate,
                                kitchenId: kitchenId,
                                mealType: "dinner",
                                notes: "notes",
                                recipeId: plan.dinner!.id,
                              ),
                            );
                          }
                        }

                        if (mealPlans.isNotEmpty) {
                          if (state.startDate == null ||
                              state.startDate!.isEmpty) {
                            log("Date Ranges: -- Setting: ${state.startDate}");
                            updateStartEndDate(plannerBloc);
                          }
                          if (state.endDate != null &&
                              state.endDate!.isNotEmpty) {
                            final existingEndDate =
                                formatStringDateToMeetBackendDate(
                                  state.endDate!,
                                );
                            log("Enddate = ${existingEndDate}");
                            if (existingEndDate.isBefore(DateTime.now())) {
                              updateStartEndDate(plannerBloc);
                            }
                          }

                          plannerBloc.add(
                            CreatePlanEvent(mealPlans: mealPlans),
                          );
                        }
                      },
              ),
            ),
          ],
        );
      },
    );
  }

  void updateStartEndDate(PlannerBloc plannerBloc) {
    final today = DateTime.now();
    final next3Dates = List.generate(3, (i) => today.add(Duration(days: i)));

    final formattedStartDate = formatDateToMeetBackendDate(next3Dates.first);
    final formattedEndDate = formatDateToMeetBackendDate(next3Dates.last);

    plannerBloc.add(
      SetDateRangeEvent(
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      ),
    );
  }

  String formatDateForBackend(String inputDate) {
    final parts = inputDate.split("/");
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    // outputDate = "2002-12-28"
    return "$year-$month-$day";
  }
}
