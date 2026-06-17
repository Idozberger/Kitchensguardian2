part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onRequestMissingItems(
  PlannerBloc bloc,
  RequestMissingItemsEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));
  final res = await bloc._requestMissingItems(
    RequestMissingItemsParams(pantry: event.pantry),
  );

  res.fold(
    (failure) => emit(
      bloc.state.copyWith(errorMessage: failure.userMessage, isLoading: false),
    ),
    (message) {
      if (event.isPlan) {
        AppToast.show(message, ToastType.success);

        emit(bloc.state.copyWith(isLoading: false));
      } else {
        emit(bloc.state.copyWith(successMessage: message, isLoading: false));
      }

      bloc._groceryBloc.add(
        RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
      );
    },
  );
}

Future<void> _onRemoveMissingIngredient(
  PlannerBloc bloc,
  RemoveMissingIngredientEvent event,
  Emitter<PlannerState> emit,
) async {
  bloc._homeBloc.add(
    RemoveMissingIngredientFromSuggestedEvent(
      recipeId: event.recipeId,
      selectedIngredients: event.selectedIngredients,
    ),
  );
  final updatedRecipes = List<RecipeModel>.from(bloc.state.recipes ?? []);
  final updatedFavRecipes = List<RecipeModel>.from(
    bloc.state.favouriteRecipes ?? [],
  );

  int recipeIndex = -1;
  for (var i = 0; i < updatedRecipes.length; i++) {
    if (updatedRecipes[i].id == event.recipeId) {
      recipeIndex = i;
      break;
    }
  }

  int favRecipeIndex = -1;
  for (var i = 0; i < updatedFavRecipes.length; i++) {
    if (updatedFavRecipes[i].id == event.recipeId) {
      favRecipeIndex = i;
      break;
    }
  }
  int weeklyPlanIndex = -1;

  for (int i = 0; i < bloc.state.getAllWeeklyPlans.length; i++) {
    final weeklyPlan = bloc.state.getAllWeeklyPlans[i];

    final breakfast = weeklyPlan.breakfast;
    if (breakfast != null && breakfast.id == event.recipeId) {
      weeklyPlanIndex = i;
      break;
    }

    final lunch = weeklyPlan.lunch;
    if (lunch != null && lunch.id == event.recipeId) {
      weeklyPlanIndex = i;
      break;
    }

    final dinner = weeklyPlan.dinner;
    if (dinner != null && dinner.id == event.recipeId) {
      weeklyPlanIndex = i;
      break;
    }
  }

  if (recipeIndex == -1 && favRecipeIndex == -1 && weeklyPlanIndex == -1) {
    devLog("Recipe not found: ${event.recipeId}");
    return;
  }

  final sourceList = favRecipeIndex != -1 ? updatedFavRecipes : updatedRecipes;
  final sourceIndex = favRecipeIndex != -1 ? favRecipeIndex : recipeIndex;

  final updatedIngredients = List<IngredientEntity>.from(
    sourceList[sourceIndex].missingIngredients,
  );

  for (var item in event.selectedIngredients) {
    for (var i = 0; i < updatedIngredients.length; i++) {
      if (updatedIngredients[i].name == item.name) {
        updatedIngredients.removeAt(i);
        break;
      }
    }

    final r = sourceList[sourceIndex];
    sourceList[sourceIndex] = r.copyWith(
      missingIngredients: List.from(updatedIngredients),
      expiringItems: [],
    );

    if (favRecipeIndex != -1) {
      emit(bloc.state.copyWith(favouriteRecipes: List.from(updatedFavRecipes)));
    } else {
      emit(bloc.state.copyWith(recipes: List.from(updatedRecipes)));
    }
  }
}

Future<void> _onRemoveMissingIngredientFromPlanEvent(
  PlannerBloc bloc,
  RemoveMissingIngredientFromPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  final updatedWeeklyPlans = bloc.state.getAllWeeklyPlans
      .map(
        (plan) => MergedRecipePlanEntity(
          date: plan.date,
          breakfast: recipeWithRemovedMissingIngredients(
            plan.breakfast as RecipeModel?,
            event.selectedIngredients,
            event.recipeId,
          ),
          lunch: recipeWithRemovedMissingIngredients(
            plan.lunch as RecipeModel?,
            event.selectedIngredients,
            event.recipeId,
          ),
          dinner: recipeWithRemovedMissingIngredients(
            plan.dinner as RecipeModel?,
            event.selectedIngredients,
            event.recipeId,
          ),
        ),
      )
      .toList();

  emit(bloc.state.copyWith(getAllWeeklyPlans: updatedWeeklyPlans));
}

Future<void> _onRequestStartRecipe(
  PlannerBloc bloc,
  RequestStartRecipeEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(requestingStartRecipe: true));

  final member = bloc._userCubit.state;
  final result = await bloc._submitRecipeStartRequest(
    SubmitRecipeStartRequestParams(
      kitchenId: event.kitchenId,
      recipeId: event.recipeId,
      recipeName: event.recipeName,
      memberUserId: member.userId,
      memberFirstName: member.firstName,
      memberLastName: member.lastName,
    ),
  );

  result.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          requestingStartRecipe: false,
        ),
      );
    },
    (_) {
      AppToast.show("Request sent to host", ToastType.success);
      emit(bloc.state.copyWith(requestingStartRecipe: false));
    },
  );
}
