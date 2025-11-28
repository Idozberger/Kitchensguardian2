// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';

class GeneratedRecipeSection extends StatelessWidget {
  final MergedMealPlanEntity mealPlan;
  final int selectedIndex;
  final String date;
  final bool isEdit;

  const GeneratedRecipeSection({
    super.key,
    required this.mealPlan,
    required this.selectedIndex,
    required this.date,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    final Widget mealContent = _buildMealContent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        RepaintBoundary(
          child: UpperTile(
            horizontalPadding: 8,
            verticalPadding: 8,
            widget: mealContent,
            color: const Color(0xffFFFBEB),
            borderColor: const Color(0xffFFDD98),
          ),
        ),
      ],
    );
  }

  Widget _buildMealContent(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return _buildMealTile(
          context,
          label: 'Breakfast',
          meal: mealPlan.breakfast,
        );
      case 1:
        return _buildMealTile(context, label: 'Lunch', meal: mealPlan.lunch);
      case 2:
      default:
        return _buildMealTile(context, label: 'Dinner', meal: mealPlan.dinner);
    }
  }

  Widget _buildMealTile(
    BuildContext context, {
    required String label,
    required MealTypeEntity? meal,
  }) {
    final bool isSameDate = mealPlan.date == date;

    if (meal != null && isSameDate) {
      return RecipeTileItem(
        isEdit: isEdit,
        isDeletedIcon: true,
        svgAsset: AppAssets.deleteSvg,
        deleteCallback: () => _showDeleteDialog(context, meal),
        recipe: meal as MealTypeModel,
        selectedDate: mealPlan.date,
        selectedMealType: label,
        isPlan: false,
      );
    }

    return _EmptyMealState(label: label);
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    MealTypeEntity meal,
  ) async {
    await showPlannerDeleteDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",

      onPrimaryPressed: () async {
        if (meal.mealplanId.isEmpty) {
          context.read<PlannerBloc>().add(
            DeleteMealPlanEvent(
              mealType: meal.mealType,
              date: meal.formatedDateString,
            ),
          );
          AppToast.show("Item removed", ToastType.success);
        } else {
          context.read<PlannerBloc>().add(
            DeletePlanFromRemoteDbEvent(mealPlanId: meal.mealplanId),
          );
          await Future.delayed(Duration(seconds: 2));
          AppToast.show("Item removed", ToastType.success);
        }

        Navigator.pop(context);
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<dynamic> showPlannerDeleteDialog({
    required BuildContext context,
    required String title,
    bool isloading = false,
    required String subtitle,
    required String primaryButtonText,
    required String secondaryButtonText,
    required VoidCallback onPrimaryPressed,
    required VoidCallback onSecondaryPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(14),
                ),
              ),
              SizedBox(height: h(10)),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(12),
                  color: const Color(0xff7B7B7B),
                ),
              ),
              SizedBox(height: h(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<PlannerBloc, PlannerState>(
                    builder: (context, state) {
                      return Flexible(
                        child: SizedBox(
                          height: h(40),
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onPrimaryPressed,
                            child: state.isLoading
                                ? Transform.scale(
                                    scale: 0.7,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  )
                                : Text(
                                    primaryButtonText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                          fontSize: t(12),
                                          color: AppColors.primaryColor,
                                        ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: h(10)),
                  Flexible(
                    child: GenericButtonWidget(
                      isLoading: false,
                      onPressed: onSecondaryPressed,
                      text: secondaryButtonText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyMealState extends StatelessWidget {
  final String label;

  const _EmptyMealState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 14),
        Text(
          'No recipe planned for $label',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
