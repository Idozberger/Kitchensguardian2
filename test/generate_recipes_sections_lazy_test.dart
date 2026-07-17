import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/generated_recipes_section.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/saved_recipes_section.dart';

/// Guards KG-15-style high-volume handling for the Generate Recipes page:
/// the saved/generated recipe cards must render as slivers (`SliverList`)
/// inside the page's `CustomScrollView`, not the old shrinkWrap
/// `ListView.separated` nested in a `SingleChildScrollView`, which built
/// every row up front regardless of scroll position.
RecipeModel _recipe(String id) {
  return RecipeModel(
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
    missingIngredients: const [],
    thumbnail: null,
    recipeId: id,
    kitchenId: '',
    date: '',
    createdAt: '',
    updatedAt: '',
    createdBy: '',
    isCompleted: false,
    notes: '',
    expiringItems: const [],
    expiringItemsCount: 0,
    expiringItemsUsed: const [],
  );
}

Future<void> _pumpSliver(WidgetTester tester, Widget sliver) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: CustomScrollView(slivers: [sliver])),
    ),
  );
}

void main() {
  testWidgets('saved recipes section renders as a lazy SliverList', (
    tester,
  ) async {
    final state = PlannerState(
      favouriteRecipes: [_recipe('1'), _recipe('2'), _recipe('3')],
    );

    await _pumpSliver(
      tester,
      SavedRecipesSection(
        state: state,
        selectedDate: '',
        selectedMealType: '',
        isPlan: false,
        isEdit: false,
      ),
    );

    expect(find.byType(SliverList), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('generated recipes section renders as a lazy SliverList', (
    tester,
  ) async {
    final state = PlannerState(recipes: [_recipe('1'), _recipe('2')]);

    await _pumpSliver(
      tester,
      GeneratedRecipesSection(
        state: state,
        selectedDate: '',
        selectedMealType: '',
        isPlan: false,
        isEdit: false,
      ),
    );

    expect(find.byType(SliverList), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
}
