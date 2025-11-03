import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_recipe_is_under_progress_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipe_tile_item.dart';

class ViewPlanDetailsPage extends StatelessWidget {
  final MergedMealPlanEntity mergedMealPlanEntity;
  const ViewPlanDetailsPage({super.key, required this.mergedMealPlanEntity});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (state.mealTypeEntity.isNotEmpty)
                    RecipeInProgressNotification(
                      padding: gapOnly(left: 20, right: 20, bottom: 0, top: 14),
                      mealTypeEntity: state.mealTypeEntity[0],
                    ),
                  Padding(
                    padding: gapSymmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mergedMealPlanEntity.breakfast != null) ...[
                          Text(
                            "Breakfast Recipe",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          gap(height: 12),
                          UpperTile(
                            widget: RecipeTileItem(
                              recipe:
                                  mergedMealPlanEntity.breakfast
                                      as MealTypeModel,
                              selectedDate: mergedMealPlanEntity.date,
                              selectedMealType: "Breakfast",
                              isPlan: false,
                            ),
                          ),
                          gap(height: 16),
                        ],
                        if (mergedMealPlanEntity.lunch != null) ...[
                          Text(
                            "Lunch Recipe",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          gap(height: 12),
                          UpperTile(
                            widget: RecipeTileItem(
                              recipe:
                                  mergedMealPlanEntity.lunch as MealTypeModel,
                              selectedDate: mergedMealPlanEntity.date,
                              selectedMealType: "Lunch",
                              isPlan: false,
                            ),
                          ),
                          gap(height: 16),
                        ],
                        if (mergedMealPlanEntity.dinner != null) ...[
                          Text(
                            "Dinner Recipe",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          gap(height: 12),
                          UpperTile(
                            widget: RecipeTileItem(
                              recipe:
                                  mergedMealPlanEntity.dinner as MealTypeModel,
                              selectedDate: mergedMealPlanEntity.date,
                              selectedMealType: "Dinner",
                              isPlan: false,
                            ),
                          ),
                          gap(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
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
      title: Text(
        "Meal Plan Details",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
