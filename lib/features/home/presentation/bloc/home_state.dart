import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_items.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class HomeState {
  final bool isLoading;
  final bool showGroceryShimmer;
  final bool requestRejecting;
  final bool requestApproving;
  final bool loadingRecipeSuggestion;
  final bool loadingWeeklyPlans;
  final bool itemsRequestLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? approveRejectError;
  final String? approveRejectSuccess;
  final List<IngredientEntity> groceryList;
  final List<PantriesDataEntity> pantryItems;
  final List<RecipeEntity> dateBasedPlan;
  final List<RecipeEntity> suggestedRecipe;
  final List<PantriesItemsEntity> lowStockItems;
  final List<PantriesItemsEntity> expiringItems;
  final List<ItemRequest> itemsRequest;

  const HomeState({
    this.isLoading = false,
    this.showGroceryShimmer = false,
    this.requestApproving = false,
    this.requestRejecting = false,
    this.loadingRecipeSuggestion = false,
    this.loadingWeeklyPlans = false,
    this.itemsRequestLoading = false,
    this.errorMessage,
    this.successMessage,
    this.approveRejectError,
    this.approveRejectSuccess,
    this.pantryItems = const [],
    this.dateBasedPlan = const [],
    this.groceryList = const [],
    this.suggestedRecipe = const [],
    this.lowStockItems = const [],
    this.expiringItems = const [],
    this.itemsRequest = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? showGroceryShimmer,
    bool? itemsRequestLoading,
    bool? requestApproving,
    bool? requestRejecting,
    bool? loadingRecipeSuggestion,
    bool? loadingWeeklyPlans,
    String? errorMessage,
    String? successMessage,
    String? approveRejectError,
    String? approveRejectSuccess,
    List<PantriesDataEntity>? pantryItems,
    List<RecipeEntity>? dateBasedPlan,
    List<IngredientEntity>? groceryList,
    List<RecipeEntity>? suggestedRecipe,
    List<PantriesItemsEntity>? lowStockItems,
    List<PantriesItemsEntity>? expiringItems,
    List<ItemRequest>? itemsRequest,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      loadingRecipeSuggestion:
          loadingRecipeSuggestion ?? this.loadingRecipeSuggestion,
      loadingWeeklyPlans: loadingWeeklyPlans ?? this.loadingWeeklyPlans,
      errorMessage: errorMessage,
      successMessage: successMessage,
      approveRejectError: approveRejectError,
      approveRejectSuccess: approveRejectSuccess,
      pantryItems: pantryItems ?? this.pantryItems,
      dateBasedPlan: dateBasedPlan ?? this.dateBasedPlan,
      groceryList: groceryList ?? this.groceryList,
      suggestedRecipe: suggestedRecipe ?? this.suggestedRecipe,
      showGroceryShimmer: showGroceryShimmer ?? this.showGroceryShimmer,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      expiringItems: expiringItems ?? this.expiringItems,
      itemsRequestLoading: itemsRequestLoading ?? this.itemsRequestLoading,
      itemsRequest: itemsRequest ?? this.itemsRequest,
      requestApproving: requestApproving ?? this.requestApproving,
      requestRejecting: requestRejecting ?? this.requestRejecting,
    );
  }
}
