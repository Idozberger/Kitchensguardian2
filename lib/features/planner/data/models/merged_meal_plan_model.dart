import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

class MergedMealPlanModel extends MergedRecipePlanEntity {
  MergedMealPlanModel({
    required super.date,
    super.breakfast,
    super.dinner,
    super.lunch,
  });

  MergedMealPlanModel copyWith({
    String? date,
    RecipeEntity? breakfast,
    RecipeEntity? lunch,
    RecipeEntity? dinner,
  }) {
    return MergedMealPlanModel(
      date: date ?? this.date,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
  }

  factory MergedMealPlanModel.fromEntity(MergedRecipePlanEntity entity) {
    return MergedMealPlanModel(
      date: entity.date,
      breakfast: entity.breakfast,
      lunch: entity.lunch,
      dinner: entity.dinner,
    );
  }
}
