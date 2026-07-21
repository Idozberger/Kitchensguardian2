part of 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';

Future<void> _onRemoveMissingIngredientFromSuggested(
  HomeBloc bloc,
  RemoveMissingIngredientFromSuggestedEvent event,
  Emitter<HomeState> emit,
) async {
  final updatedSuggestedRecipes = List<RecipeModel>.from(
    bloc.state.suggestedRecipe,
  );

  bool updated = false;

  for (var i = 0; i < updatedSuggestedRecipes.length; i++) {
    final recipe = updatedSuggestedRecipes[i];
    if (recipe.id == event.recipeId) {
      final updatedIngredients =
          List<IngredientEntity>.from(recipe.missingIngredients)..removeWhere(
            (ing) => event.selectedIngredients.any((e) => e.name == ing.name),
          );

      updatedSuggestedRecipes[i] = recipe.copyWith(
        missingIngredients: updatedIngredients,
      );

      updated = true;
      break;
    }
  }

  if (updated) {
    emit(bloc.state.copyWith(suggestedRecipe: updatedSuggestedRecipes));
  }
}

Future<void> _onRespondToItemRejectRequestEvent(
  HomeBloc bloc,
  RespondToItemRejectRequestEvent event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(requestRejecting: true));

  final res = await bloc._respondToItemRequest(
    RespondToItemRequestParams(
      action: event.action,
      requestId: event.requestId,
      rejectReason: event.rejectReason,
    ),
  );

  await res.fold<Future<void>>(
    (failure) async {
      emit(
        bloc.state.copyWith(
          requestRejecting: false,
          approveRejectError: failure.userMessage,
          approveRejectSuccess: null,
        ),
      );
    },
    (message) async {
      emit(
        bloc.state.copyWith(
          requestRejecting: false,
          approveRejectSuccess: message,
          approveRejectError: null,
        ),
      );
    },
  );
}

Future<void> _onRespondToItemRequestEvent(
  HomeBloc bloc,
  RespondToItemRequestEvent event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(requestApproving: true));

  final res = await bloc._respondToItemRequest(
    RespondToItemRequestParams(
      action: event.action,
      requestId: event.requestId,
      rejectReason: event.rejectReason,
    ),
  );

  await res.fold<Future<void>>(
    (failure) async {
      emit(
        bloc.state.copyWith(
          requestApproving: false,
          approveRejectError: failure.userMessage,
          approveRejectSuccess: null,
        ),
      );
    },
    (message) async {
      emit(
        bloc.state.copyWith(
          requestApproving: false,
          approveRejectSuccess: message,
          approveRejectError: null,
        ),
      );
    },
  );
}

Future<void> _onGetAllRequestedItems(
  HomeBloc bloc,
  GetAllRequestedItemsEvent event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(itemsRequestLoading: true));

  final res = await bloc._getAllRequestedItems(
    GetAllRequestedItemsParams(kitchenId: event.kitchenId),
  );

  await res.fold<Future<void>>(
    (failure) async {
      emit(bloc.state.copyWith(itemsRequestLoading: false));
    },
    (items) async {
      emit(
        bloc.state.copyWith(itemsRequest: items, itemsRequestLoading: false),
      );
    },
  );
}

Future<void> _onGetRecipeSuggestion(
  HomeBloc bloc,
  GetRecipeSuggestionEvent event,
  Emitter<HomeState> emit,
) async {
  if (bloc.state.loadingRecipeSuggestion) return;
  emit(bloc.state.copyWith(loadingRecipeSuggestion: true));

  final res = await bloc._getRecipeSuggestionUsecase(
    GetRecipeSuggestionUsecaseParams(event.kitchenId),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          loadingRecipeSuggestion: false,
          errorMessage: failure.userMessage,
        ),
      );
    },
    (recipe) {
      final bool isValid =
          recipe.title.isNotEmpty && recipe.recipeShortSummary.isNotEmpty;

      emit(
        bloc.state.copyWith(
          loadingRecipeSuggestion: false,
          suggestedRecipe: isValid ? [recipe] : [],
        ),
      );
    },
  );
}

Future<void> _onGetGenerateGroceryList(
  HomeBloc bloc,
  GenerateGroceryList event,
  Emitter<HomeState> emit,
) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final allWeeklyPlans = bloc.state.dateBasedPlan;
  final lowStockItems = bloc.state.lowStockItems;

  final List<IngredientEntity> missingIngredientNames = [];

  final dateFormatter = DateFormat('yyyy-MM-dd');

  for (var plan in allWeeklyPlans) {
    try {
      final planDate = dateFormatter.parse(plan.date);

      if (planDate.isBefore(today)) {
        continue;
      }

      for (var ingredient in plan.ingredients) {
        missingIngredientNames.add(ingredient);
        devPrint(
          'Grocery: ${ingredient.amount} → ${DateFormat('EEE, MMM d').format(planDate)}',
        );
      }
    } on FormatException catch (e) {
      devPrint('Invalid date format in plan: ${plan.date}, error: $e');
    }
  }
  for (var i = 0; i < lowStockItems.length; i++) {
    missingIngredientNames.add(
      IngredientEntity(
        amount: formatQuantity(lowStockItems[i].quantity, grouped: false),
        name: lowStockItems[i].name,
        unit: lowStockItems[i].unit,
      ),
    );
  }
  missingIngredientNames.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );

  emit(bloc.state.copyWith(groceryList: missingIngredientNames));
}

Future<void> _onCreateKitchenEvent(
  HomeBloc bloc,
  CreateKitchenEventForHome event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._createKitchen(
    CreateKitchenParams(
      kitchenName: event.kitchenName,
      unitSystem: event.unitSystem,
    ),
  );

  await res.fold(
    (failure) async {
      emit(
        bloc.state.copyWith(
          isLoading: false,
          errorMessage: failure.userMessage,
        ),
      );
    },
    (kitchen) async {
      bloc._userCubit.updateActiveKitchenIdInvitationCodeAndRole(
        kitchenName: event.kitchenName,
        activeKitchenId: kitchen.kitchenId,
        invitationCode: kitchen.invitationCode,
        role: "host",
      );

      // Seed with the system the user just picked so the first frame is right.
      bloc._userCubit.applyUnitSystemForKitchen(
        kitchenId: kitchen.kitchenId,
        fromKitchen: unitSystemToApi(event.unitSystem),
      );

      await bloc._saveOrUpdateUserKitchen(
        kitchen: kitchen,
        kitchenName: event.kitchenName,
      );

      emit(
        bloc.state.copyWith(isLoading: false, successMessage: kitchen.message),
      );
      bloc.add(GetPantriesItemsEventForHome(kitchenId: kitchen.kitchenId));
    },
  );
}
