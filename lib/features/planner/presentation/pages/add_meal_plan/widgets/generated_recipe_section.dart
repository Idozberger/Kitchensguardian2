import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
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
    await showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      isloading: false,
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
