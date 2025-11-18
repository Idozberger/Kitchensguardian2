class MealPlanModel {
  final String date;
  final String kitchenId;
  final String mealType;
  final String notes;
  final String recipeId;

  MealPlanModel({
    required this.date,
    required this.kitchenId,
    required this.mealType,
    required this.notes,
    required this.recipeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'kitchenId': kitchenId,
      'mealType': mealType,
      'notes': notes,
      'recipeId': recipeId,
    };
  }

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      date: json['date'],
      kitchenId: json['kitchenId'],
      mealType: json['mealType'],
      notes: json['notes'],
      recipeId: json['recipeId'],
    );
  }
}
