import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';

class MergedMealPlanEntity {
  final String date;
  final MealTypeEntity? breakfast;
  final MealTypeEntity? lunch;
  final MealTypeEntity? dinner;

  MergedMealPlanEntity({
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
  });
}
