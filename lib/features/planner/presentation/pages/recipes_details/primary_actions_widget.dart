import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';

import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class PrimaryActionsWidget extends StatelessWidget {
  final RecipeEntity recipe;
  final bool addPlanDummyLoading;
  final bool isFinishing;
  final bool isPlan;
  final bool isRequestedRecipe;
  final bool startRecipe;
  final bool completed;
  final bool canRequestToStartRecipe;
  final VoidCallback onStartOrRequestRecipe;
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
    this.completed = false,
    this.isRequestedRecipe = false,
    required this.onStartOrRequestRecipe,
    required this.addToWeeklyPlanCallback,
    required this.onFinish,
    required this.onCancel,
    required this.canRequestToStartRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: BlocConsumer<PlannerBloc, PlannerState>(
        listenWhen: (previous, current) {
          return previous.isCheckingMissingIngredients &&
              !current.isCheckingMissingIngredients;
        },
        listener: (context, state) {
          if (state.hasMissingIngredients) {
            AppToast.show(
              "Some ingredients are missing. Please add the required ingredients before continuing.",
              ToastType.warning,
              gravity: ToastGravity.TOP,
              toastLength: Toast.LENGTH_LONG,
            );
          } else {
            primaryButtonsCallback(context);
          }
        },
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
                      isLoading:
                          state.requestingStartRecipe ||
                          state.isCheckingMissingIngredients,
                      isDisabled: isRequestedRecipe
                          ? false
                          : context.read<UserCubit>().state.role == "member" &&
                                    canRequestToStartRecipe == false ||
                                completed,
                      onPressed: () {
                        _checkMissingIngredients(context);
                      },
                      text: isRequestedRecipe
                          ? "Start Recipe"
                          : completed
                          ? "Recipe Completed"
                          : context.read<UserCubit>().state.role == "member"
                          ? canRequestToStartRecipe
                                ? "Request to Start Recipe"
                                : "Member Can Not Start Recipe"
                          : "Start Recipe",
                    ),
              if (isPlan) ...[
                gap(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: h(40),
                  child: OutlinedButton(
                    onPressed: addToWeeklyPlanCallback,
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

  void _checkMissingIngredients(BuildContext context) {
    final kitchenId = context.read<UserCubit>().state.activeKitchenId;
    final recipeId = recipe.recipeId.isEmpty ? recipe.id : recipe.recipeId;

    context.read<PlannerBloc>().add(
      CheckMissingIngredientsEvent(kitchenId: kitchenId, recipeId: recipeId),
    );
  }

  void primaryButtonsCallback(BuildContext context) {
    if (isRequestedRecipe) {
      onStartOrRequestRecipe();
      return;
    }

    if (context.read<UserCubit>().state.role == "member" &&
        canRequestToStartRecipe == false) {
      AppToast.show("Member Can Not Start Recipe", ToastType.error);
    } else if (context.read<UserCubit>().state.role == "member" &&
        canRequestToStartRecipe) {
      onStartOrRequestRecipe();
    } else if (context.read<UserCubit>().state.role != "member") {
      onStartOrRequestRecipe();
    }
  }
}
