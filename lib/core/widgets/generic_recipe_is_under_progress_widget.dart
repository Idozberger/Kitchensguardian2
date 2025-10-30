import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:go_router/go_router.dart';

class RecipeInProgressNotification extends StatelessWidget {
  final MealTypeEntity mealTypeEntity;
  final bool canCancel;
  final VoidCallback? onCancelRecipe;
  final EdgeInsetsGeometry padding;
  const RecipeInProgressNotification({
    super.key,
    required this.mealTypeEntity,
    required this.padding,
    this.canCancel = false,
    this.onCancelRecipe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: UpperTile(
        verticalPadding: 12,
        color: Color(0xffFFFBEB),
        borderColor: Color(0xffFFDD98),
        widget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: w(14),
          children: [
            Row(
              spacing: w(12),
              children: [
                SvgPicture.asset(
                  AppAssets.notificationSvg,
                  color: AppColors.primaryColor,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: h(4),
                  children: [
                    Text(
                      'Recipe Under Making',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(
                      width: w(200),
                      child: Text(
                        mealTypeEntity.title,
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              spacing: h(6),
              children: [
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      Routes.generateRecipesDetails,
                      extra: {
                        "meal_type_entity": mealTypeEntity,
                        "is_plan": false,
                      },
                    );
                  },
                  child: Text(
                    "Resume",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: Colors.blueGrey),
                  ),
                ),
                if (canCancel)
                  GestureDetector(
                    onTap: onCancelRecipe,
                    child: Text(
                      "Clear",
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
