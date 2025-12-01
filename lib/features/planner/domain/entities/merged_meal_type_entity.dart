import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';

class MergedRecipePlanEntity {
  final String date;
  final RecipeEntity? breakfast;
  final RecipeEntity? lunch;
  final RecipeEntity? dinner;

  MergedRecipePlanEntity({
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
  });
}
