import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditMealPage extends StatefulWidget {
  final MergedMealPlanEntity mergedMealPlanEntity;
  const EditMealPage({super.key, required this.mergedMealPlanEntity});

  @override
  State<EditMealPage> createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  late MergedMealPlanEntity _mealPlan;
  late DateTime _selectedDate;
  late DateTime _previousSelectedDate;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _mealPlan = widget.mergedMealPlanEntity;

    _selectedDate = parseDate(_mealPlan.date);

    _previousSelectedDate = DateFormat('dd/MM/yyyy').parse(_mealPlan.date);

    _selectedIndex = _initialSelectedIndex();
  }

  int _initialSelectedIndex() {
    if (_mealPlan.breakfast != null) return 0;
    if (_mealPlan.lunch != null) return 1;
    if (_mealPlan.dinner != null) return 2;
    return 0; // fallback
  }

  void _updateSelectedIndex(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _onDateChanged(DateTime newDate) {
    // setState(() {
    //   // _selectedDate = newDate;
    //   // _mealPlan = _mealPlan.copyWith(
    //   //   date: DateFormat('dd/MM/yyyy').format(newDate),
    //   // );
    // });
  }

  void _onSavePressed() {
    context.pop(_mealPlan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatePickerSection(
                  startDate: _selectedDate,
                  onChanged: _onDateChanged,
                ),
                gap(height: 20),
                MealTypeSection(
                  selectedIndex: _selectedIndex,
                  onSelected: _updateSelectedIndex,
                ),
                gap(height: 20),
                GeneratedRecipeSectionEdit(
                  date: _mealPlan.date,
                  mealPlan: _mealPlan,
                  selectedIndex: _selectedIndex,
                ),
                // gap(height: 18),
                // ActionButtons(
                //   onCancel: () => context.pop(),
                //   onSave: _onSavePressed,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text('Edit Day Plan', style: theme.textTheme.headlineLarge),
    );
  }
}

class DatePickerSection extends StatelessWidget {
  final DateTime startDate;
  final ValueChanged<DateTime> onChanged;
  const DatePickerSection({
    super.key,
    required this.startDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SelectDateWidget(
      entitlementIsActive: AppConstants.entitlementIsActive,
      startDate: startDate,
      onChanged: onChanged,
    );
  }
}

class MealTypeSection extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  const MealTypeSection({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal Type', style: theme.textTheme.headlineLarge),
        gap(height: 20),
        MealTypeTile(
          index: 0,
          text: 'Breakfast',
          iconPath: AppAssets.breakfastSvg,
          isSelected: selectedIndex == 0,
          onTap: () => onSelected(0),
        ),
        gap(height: 10),
        MealTypeTile(
          index: 1,
          text: 'Lunch',
          iconPath: AppAssets.lunchSvg,
          isSelected: selectedIndex == 1,
          onTap: () => onSelected(1),
        ),
        gap(height: 10),
        MealTypeTile(
          index: 2,
          text: 'Dinner',
          iconPath: AppAssets.dinnerSvg,
          isSelected: selectedIndex == 2,
          onTap: () => onSelected(2),
        ),
      ],
    );
  }
}

class MealTypeTile extends StatelessWidget {
  final int index;
  final String text;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const MealTypeTile({
    super.key,
    required this.index,
    required this.text,
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      callback: onTap,
      height: h(51),
      borderColor: isSelected ? const Color(0xffFFDD98) : null,
      color: isSelected ? const Color(0xffFFFBEB) : null,
      widget: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: SvgPicture.asset(iconPath),
          ),
          SizedBox(width: w(15)),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium!.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class GeneratedRecipeSectionEdit extends StatelessWidget {
  final MergedMealPlanEntity mealPlan;
  final int selectedIndex;
  final String date;
  const GeneratedRecipeSectionEdit({
    super.key,
    required this.mealPlan,
    required this.selectedIndex,
    required this.date,
  });

  Widget _emptyState(BuildContext context, String mealLabel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        gap(height: 8),
        Text(
          'No recipe planned for $mealLabel today',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        TextButton(
          onPressed: () {
            context.pushNamed(
              Routes.generateRecipes,
              extra: {
                "selected_date": date,
                "selected_meal_type": mealLabel,
                "is_plan": true,
              },
            );
          },
          child: const Text('Find Recipe'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child;

    switch (selectedIndex) {
      case 0:
        child = (mealPlan.breakfast != null)
            ? RecipeTileItem(
                isDeletedIcon: true,
                svgAsset: AppAssets.deleteSvg,
                deleteCallback: () {
                  _showDeleteDialog(context, mealPlan.breakfast!);
                },
                recipe: mealPlan.breakfast! as MealTypeModel,
                selectedDate: mealPlan.date,
                selectedMealType: 'Breakfast',
                isPlan: false,
              )
            : _emptyState(context, 'breakfast');
        break;
      case 1:
        child = (mealPlan.lunch != null)
            ? RecipeTileItem(
                isDeletedIcon: true,
                svgAsset: AppAssets.deleteSvg,
                deleteCallback: () {
                  _showDeleteDialog(context, mealPlan.lunch!);
                },
                recipe: mealPlan.lunch! as MealTypeModel,
                selectedDate: mealPlan.date,
                selectedMealType: 'Lunch',
                isPlan: false,
              )
            : _emptyState(context, 'lunch');
        break;
      case 2:
      default:
        child = (mealPlan.dinner != null)
            ? RecipeTileItem(
                isDeletedIcon: true,
                svgAsset: AppAssets.deleteSvg,
                deleteCallback: () {
                  _showDeleteDialog(context, mealPlan.dinner!);
                },
                recipe: mealPlan.dinner! as MealTypeModel,
                selectedDate: mealPlan.date,
                selectedMealType: 'Dinner',
                isPlan: false,
              )
            : _emptyState(context, 'dinner');
        break;
    }

    return Padding(
      padding: gapSymmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generated Recipe', style: theme.textTheme.headlineLarge),
          gap(height: 12),
          UpperTile(
            horizontalPadding: 8,
            verticalPadding: 8,
            widget: child,
            color: Color(0xffFFFBEB),
            borderColor: const Color(0xffFFDD98),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _showDeleteDialog(BuildContext context, MealTypeEntity plan) {
    return showCustomGenericDialog(
      context: context,
      title: "Delete Plan",
      subtitle: "Are you sure you want to delete this plan?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        context.read<PlannerBloc>().add(
          DeleteMealTypeFromWeeklyPlanEvent(
            selectedDate: plan.formatedDateString,
            mealType: plan.mealType,
          ),
        );
        AppToast.show("Item removed", ToastType.success);
        context.pop();
        context.pop();
      },
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 12),
      child: Row(
        children: [
          Flexible(
            child: SizedBox(
              width: double.infinity,
              height: h(40),
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(14),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: h(10)),
          Flexible(
            child: SizedBox(
              width: double.infinity,
              height: h(40),
              child: ElevatedButton(
                onPressed: onSave,
                child: Text(
                  'Save Edit',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(14),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
