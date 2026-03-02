import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';

import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class PrimaryActionsWidget extends StatelessWidget {
  final RecipeEntity recipe;
  final bool addPlanDummyLoading;
  final bool isFinishing;
  final bool isPlan;
  final bool startRecipe;
  final VoidCallback onStartRecipe;
  final VoidCallback onFinish;
  final VoidCallback onCancel;
  final VoidCallback addToWeeklyPlanCallback;

  const PrimaryActionsWidget({
    super.key,
    required this.addPlanDummyLoading,
    required this.recipe,
    required this.isPlan,
    required this.isFinishing,
    required this.startRecipe,
    required this.onStartRecipe,
    required this.addToWeeklyPlanCallback,
    required this.onFinish,
    required this.onCancel,
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
                            isLoading: isFinishing,
                            onPressed: onFinish,
                            text: "Finish Recipe",
                            backgroundColor: Colors.white,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: w(12)),
                        Flexible(
                          child: GenericButtonWidget(
                            onPressed: onCancel,
                            text: "Cancel Recipe",
                            backgroundColor: Colors.white,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  : GenericButtonWidget(
                      isLoading: state.requestingStartRecipe,
                      isDisabled: recipe.missingItems,
                      onPressed: () {
                        if (recipe.missingItems == false) {
                          onStartRecipe();
                        } else {
                          AppToast.show(
                            "Missing ingredients! Please restock before starting this recipe.",
                            ToastType.error,
                          );
                        }
                      },
                      text: recipe.missingItems == true
                          ? "Missing Ingredients"
                          : context.read<UserCubit>().state.role == "member"
                          ? "Request to Start Recipe"
                          : "Start Recipe",
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
                    child: state.addingToWeeklyPlan || addPlanDummyLoading
                        ? Transform.scale(
                            scale: 0.7,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                        : Text(
                            "Add to Menu",
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
