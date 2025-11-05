import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

class MergedMealPlanModel extends MergedMealPlanEntity {
  MergedMealPlanModel({
    required super.date,
    super.breakfast,
    super.dinner,
    super.lunch,
  });

  MergedMealPlanModel copyWith({
    String? date,
    MealTypeEntity? breakfast,
    MealTypeEntity? lunch,
    MealTypeEntity? dinner,
  }) {
    return MergedMealPlanModel(
      date: date ?? this.date,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
  }

  factory MergedMealPlanModel.fromEntity(MergedMealPlanEntity entity) {
    return MergedMealPlanModel(
      date: entity.date,
      breakfast: entity.breakfast,
      lunch: entity.lunch,
      dinner: entity.dinner,
    );
  }
}
