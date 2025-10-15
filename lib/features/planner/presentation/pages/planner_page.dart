import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_date_picker_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/day_plan_tile.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/meal_tile.dart';
import 'package:go_router/go_router.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late PlannerBloc plannerBloc;
  int _visiblePlansCount = 5;

  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    getAllWeeklyPlans();
    super.initState();
  }

  void getAllWeeklyPlans() {
    plannerBloc.add(GetAllWeeklyPlansEvent());
  }

  void _loadMore() {
    setState(() {
      _visiblePlansCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 14),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    gap(height: 15),
                    if (state.getAllWeeklyPlans != null) ...[
                      if (state.getAllWeeklyPlans!.isNotEmpty)
                        SelectDateWidget(
                          startDate: DateTime.now(),
                          onChanged: (date) => debugPrint("Date: $date"),
                        ),
                      gap(height: 15),
                    ],
                    // Date Picker
                    if (state.getAllWeeklyPlans == null ||
                        state.getAllWeeklyPlans!.isEmpty) ...[
                      Center(
                        child: EmptyStateWidget(
                          context,
                          imagePath: AppAssets.noKitchenFound,
                          title: 'No Kitchen found',
                        ),
                      ),
                    ] else
                      ..._buildPaginatedPlans(state.getAllWeeklyPlans!),

                    if (state.getAllWeeklyPlans != null)
                      if (_visiblePlansCount < state.getAllWeeklyPlans!.length)
                        Center(
                          child: GenericButtonWidget(
                            onPressed: _loadMore,
                            width: w(180),
                            text: "Load More",
                          ),
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildPaginatedPlans(List<MealTypeEntity> plans) {
    List<Widget> widgets = [];
    final count = plans.length < _visiblePlansCount
        ? plans.length
        : _visiblePlansCount;
    for (int i = 0; i < count; i++) {
      if (i < 3) {
        widgets.add(
          DayPlanTile(
            dayLabel: plans[i].formatedDateString,
            meals: [
              MealTile(mealType: "Breakfast", mealName: plans[i].title),
              MealTile(mealType: "Lunch", mealName: plans[i].title),
              MealTile(mealType: "Dinner", mealName: plans[i].title),
            ],
            viewRecipe: () {},
            addToCart: () {},
            deletePlan: () {
              plannerBloc.add(DeletePlanEvent(plans[i].formatedDateString));
            },
            editPlan: () {},
          ),
        );
      } else {
        widgets.add(unlockPremiumWidget(context));
      }
      widgets.add(gap(height: 20));
    }

    return widgets;
  }

  Widget unlockPremiumWidget(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DayPlanTile(
          dayLabel: "Premium Plan (Locked)",
          meals: const [
            MealTile(mealType: "Breakfast", mealName: "Avocado Toast"),
            MealTile(mealType: "Lunch", mealName: "Grilled Chicken"),
            MealTile(mealType: "Dinner", mealName: "Pasta Salad"),
          ],
          viewRecipe: () {},
          addToCart: () {},
          deletePlan: () {},
          editPlan: () {},
        ),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.white.withOpacity(0.05)),
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
                onPressed: () => context.push(Routes.subscription),
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
