import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_menu.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';

class DayPlanTile extends StatelessWidget {
  final String dayLabel;
  final List<MealTile> meals;
  final VoidCallback viewRecipe;
  final VoidCallback addToCart;
  final VoidCallback deletePlan;
  final VoidCallback editPlan;

  const DayPlanTile({
    super.key,
    required this.dayLabel,
    required this.meals,
    required this.viewRecipe,
    required this.addToCart,
    required this.deletePlan,
    required this.editPlan,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          gap(height: 5),
          ...meals.map((meal) => meal),
          const Divider(color: Color(0xffE6E6E6)),
          gap(height: 12),
          _buildFooterButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(AppAssets.avatar, height: h(34)),
            SizedBox(width: w(13)),
            Text(dayLabel, style: Theme.of(context).textTheme.headlineLarge),
          ],
        ),
        DayPlanMenu(deletePlan: deletePlan, editPlan: editPlan),
      ],
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return SizedBox(
      height: h(40),
      child: OutlinedButton(
        onPressed: () => viewRecipe(),
        child: Text(
          "View Plan Details",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(14),
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
