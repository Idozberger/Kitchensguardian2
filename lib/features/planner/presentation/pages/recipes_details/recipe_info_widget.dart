import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class RecipeInfoWidget extends StatelessWidget {
  final MealTypeEntity recipe;

  const RecipeInfoWidget({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20),
      child: UpperTile(
        widget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.missingItems)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "Some items are missing*",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontSize: t(10),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              recipe.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            gap(height: 15),
            _buildInfoRow(AppAssets.gramSvg, recipe.calories, context),
            gap(height: 15),
            _buildInfoRow(AppAssets.stopWatchSvg, recipe.cookingTime, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String text, BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        SizedBox(width: w(6)),
        Text(text, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
