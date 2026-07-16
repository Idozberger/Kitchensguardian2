import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/planner/presentation/pages/favourite_food_page.dart';

/// Guards KG-15-style high-volume handling for the Favourite Recipes list:
/// it must stay a lazily-built `ListView.builder`, not the old
/// `SingleChildScrollView` + shrinkWrap `ListView.builder` pattern that
/// built every row up front regardless of scroll position.
RecipeEntity _recipe(String id) {
  return RecipeEntity(
    id: id,
    mealplanId: '',
    title: 'Recipe $id',
    calories: '0',
    cookingTime: '10 min',
    recipeShortSummary: '',
    cookingSteps: const [],
    ingredients: const [],
    missingItems: false,
    available: true,
    mealType: '',
    formatedDateString: '',
    thumbnail: null,
    missingIngredients: const [],
    recipeId: id,
    kitchenId: '',
    date: '',
    createdAt: '',
    updatedAt: '',
    createdBy: '',
    isCompleted: false,
    notes: '',
  );
}

void main() {
  testWidgets('favourite recipes list stays a lazy ListView.builder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FavouriteRecipesListView(recipes: [_recipe('1'), _recipe('2')]),
        ),
      ),
    );

    final listView = tester.widget<ListView>(find.byType(ListView));

    expect(listView.shrinkWrap, isFalse);
    expect(listView.physics, isNot(isA<NeverScrollableScrollPhysics>()));
    expect(
      (listView.childrenDelegate as SliverChildBuilderDelegate).childCount,
      3, // header + 2 recipes
    );
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
}
