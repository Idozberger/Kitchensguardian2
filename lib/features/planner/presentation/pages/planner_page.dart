import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/weekly_date_selector_widget.dart';
import 'package:go_router/go_router.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                gap(height: 20),
                WeeklyDateSelector(
                  today: DateTime.now(),
                  onChanged: (selectedDate) {
                    debugPrint("User selected: $selectedDate");
                  },
                ),
                gap(height: 20),
                const DayPlanTile(
                  dayLabel: "Sunday 12, 2025",
                  meals: [
                    MealTile(
                      mealType: "Breakfast",
                      mealName: "Greek Yogurt Parfait",
                    ),
                    MealTile(mealType: "Lunch", mealName: "Quinoa Buddha Bowl"),
                    MealTile(mealType: "Dinner", mealName: "Pasta Primavera"),
                  ],
                ),
                gap(height: 20),
                const DayPlanTile(
                  dayLabel: "Sunday 12, 2025",
                  meals: [
                    MealTile(mealType: "Breakfast", mealName: "Avocado Toast"),
                    MealTile(mealType: "Lunch", mealName: "Grilled Chicken"),
                    MealTile(mealType: "Dinner", mealName: "Pasta Salad"),
                  ],
                ),
                gap(height: 20),
                unlockPremiumWidget(),
                gap(height: 20),
                unlockPremiumWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget unlockPremiumWidget() {
    return Stack(
      children: [
        const DayPlanTile(
          dayLabel: "Sunday 12, 2025",
          meals: [
            MealTile(mealType: "Breakfast", mealName: "Avocado Toast"),
            MealTile(mealType: "Lunch", mealName: "Grilled Chicken"),
            MealTile(mealType: "Dinner", mealName: "Pasta Salad"),
          ],
        ),

        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Color(0xffffffff).withOpacity(0.1)),
            ),
          ),
        ),

        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppAssets.crownImage, height: h(68)),
              gap(height: 11),
              GenericButtonWidget(
                width: w(160),
                onPressed: () {},
                text: "Unlock Premium",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Plan your meals for the week ahead",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 15),
          GenericButtonWidget(
            onPressed: () => context.push(Routes.addMeal),
            text: "+ Add Meal",
          ),
        ],
      ),
    );
  }
}

class DayPlanTile extends StatelessWidget {
  final String dayLabel;
  final List<MealTile> meals;

  const DayPlanTile({super.key, required this.dayLabel, required this.meals});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context),
          gap(height: 26),
          ...meals.map(
            (meal) => Padding(
              padding: EdgeInsets.only(bottom: h(15)),
              child: meal,
            ),
          ),
          const Divider(color: Color(0xffE6E6E6)),
          gap(height: 15),
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
        const DayPlanMenu(),
      ],
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: h(40),
            child: OutlinedButton(
              onPressed: () {},
              child: Text(
                "View Recipe",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: t(14),
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: h(10)),
        Expanded(
          child: SizedBox(
            height: h(40),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                "Add to Cart",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: t(14),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MealTile extends StatelessWidget {
  final String mealType;
  final String mealName;

  const MealTile({super.key, required this.mealType, required this.mealName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(AppAssets.addSvg),
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(
            "$mealType: ",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.black),
          ),
          Flexible(
            child: Text(
              mealName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xff787878),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayPlanMenu extends StatelessWidget {
  const DayPlanMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.white,
      offset: Offset(w(-20), 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(h(10)),
        side: const BorderSide(color: Color(0xffD4D2D2)),
      ),
      onSelected: (value) {
        switch (value) {
          case 0:
            debugPrint("Edit Day Plan clicked");
            context.push(Routes.editMeal);
            break;
          case 1:
            debugPrint("Share Day Plan clicked");
            AppToast.show("Share Day Plan", ToastType.success);

            break;
          case 2:
            debugPrint("Clear Day Plan clicked");
            AppToast.show("Clear Day Plan", ToastType.success);

            break;
        }
      },
      itemBuilder: (context) => [
        _menuItem(
          context,
          value: 0,
          icon: AppAssets.editSvg,
          label: "Edit Day Plan",
          textColor: Colors.black,
        ),
        _menuItem(
          context,
          value: 1,
          icon: AppAssets.shareSvg,
          label: "Share Day Plan",
          textColor: Colors.black,
        ),
        _menuItem(
          context,
          value: 2,
          icon: AppAssets.deleteSvg,
          label: "Clear Day Plan",
          textColor: Colors.red,
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  PopupMenuItem<int> _menuItem(
    BuildContext context, {
    required int value,
    required String icon,
    required String label,
    required Color textColor,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          SvgPicture.asset(icon),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
