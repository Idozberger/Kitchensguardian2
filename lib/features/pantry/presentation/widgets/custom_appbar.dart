import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

/// Custom AppBar
AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leadingWidth: w(55),
    leading: Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(h(70)),
      child: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: h(40),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(Routes.scanMeal);
                  },
                  icon: SvgPicture.asset(AppAssets.scanSvg),
                  label: Text(
                    "Scan",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: t(12),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: w(10)),
            Expanded(
              child: SizedBox(
                height: h(40),
                child: ElevatedButton.icon(
                  onPressed: () => context.push(Routes.addItem),
                  icon: SvgPicture.asset(AppAssets.addSvg),
                  label: Text(
                    "Add Item",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: t(12),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    title: Text("My Pantry", style: Theme.of(context).textTheme.headlineLarge),
  );
}
