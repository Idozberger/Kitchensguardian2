import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';
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
                // WeeklyDateSelector(
                //   today: DateTime.now(),
                //   onChanged: (selectedDate) {
                //     debugPrint("User selected: $selectedDate");
                //   },
                // ),
                SelectDateWidget(
                  startDate: DateTime.now(),
                  onChanged: (DateTime date) {
                    debugPrint("Date $date");
                  },
                ),
                gap(height: 20),
                DayPlanTile(
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
                unlockPremiumWidget(context),
                gap(height: 20),
                unlockPremiumWidget(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget unlockPremiumWidget(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
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
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Color(0xffffffff).withOpacity(0.04)),
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
                onPressed: () {
                  context.push(Routes.subscription);
                },
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
