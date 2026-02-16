import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class HomeState {
  final bool isLoading;
  final bool showGroceryShimmer;
  final bool loadingRecipeSuggestion;
  final bool loadingWeeklyPlans;
  final String? errorMessage;
  final String? successMessage;
  final List<IngredientEntity> groceryList;
  final List<PantriesDataEntity> pantryItems;
  final List<RecipeEntity> dateBasedPlan;
  final List<RecipeEntity> suggestedRecipe;
  final List<PantriesItemsEntity> lowStockItems;
  final List<PantriesItemsEntity> expiringItems;

  const HomeState({
    this.isLoading = false,
    this.showGroceryShimmer = false,
    this.loadingRecipeSuggestion = false,
    this.loadingWeeklyPlans = false,
    this.errorMessage,
    this.successMessage,

    this.pantryItems = const [],
    this.dateBasedPlan = const [],
    this.groceryList = const [],
    this.suggestedRecipe = const [],
    this.lowStockItems = const [],
    this.expiringItems = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? showGroceryShimmer,
    bool? loadingRecipeSuggestion,
    bool? loadingWeeklyPlans,
    String? errorMessage,
    List<PantriesDataEntity>? pantryItems,
    List<RecipeEntity>? dateBasedPlan,
    String? successMessage,
    List<IngredientEntity>? groceryList,
    List<RecipeEntity>? suggestedRecipe,
    List<PantriesItemsEntity>? lowStockItems,
    List<PantriesItemsEntity>? expiringItems,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      loadingRecipeSuggestion:
          loadingRecipeSuggestion ?? this.loadingRecipeSuggestion,
      loadingWeeklyPlans: loadingWeeklyPlans ?? this.loadingWeeklyPlans,
      errorMessage: errorMessage,
      successMessage: successMessage,
      pantryItems: pantryItems ?? this.pantryItems,
      dateBasedPlan: dateBasedPlan ?? this.dateBasedPlan,
      groceryList: groceryList ?? this.groceryList,
      suggestedRecipe: suggestedRecipe ?? this.suggestedRecipe,
      showGroceryShimmer: showGroceryShimmer ?? this.showGroceryShimmer,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      expiringItems: expiringItems ?? this.expiringItems,
    );
  }
}
