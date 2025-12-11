import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';

class HomeState {
  final bool isLoading;
  final bool showGroceryShimmer;
  final bool loadingRecipeSuggestion;
  final bool loadingWeeklyPlans;
  final String? errorMessage;
  final String? successMessage;
  final List<String> groceryList;
  final List<PantriesDataEntity> pantryItems;
  final List<RecipeEntity> dateBasedPlan;
  final List<RecipeEntity> suggestedRecipe;

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
    List<String>? groceryList,
    List<RecipeEntity>? suggestedRecipe,
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
    );
  }
}
