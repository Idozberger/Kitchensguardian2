part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onUpdateRecipeFinishedState(
  PlannerBloc bloc,
  UpdateRecipeFinishedState event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isRecipeFinished: false));
}

Future<void> _onUpdateMealTypeSelectedAndDate(
  PlannerBloc bloc,
  UpdateTypeSelectedAndDateEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(
    bloc.state.copyWith(
      mealTypeSelectedIndex: event.index,
      selectedDate: event.date,
    ),
  );
}

Future<void> _onGetFavouriteRecipes(
  PlannerBloc bloc,
  GetFavouriteRecipesEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isFavLoading: true));
  final res = await bloc._favouriteRecipes(
    FavouriteRecipeParams(event.kitchenId),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
          isFavLoading: false,
        ),
      );
    },
    (favouriteRecipes) {
      emit(
        bloc.state.copyWith(
          favouriteRecipes: favouriteRecipes,
          isLoading: false,
          isFavLoading: false,
        ),
      );
    },
  );
}

Future<void> _onGenerateRecipes(
  PlannerBloc bloc,
  GenerateRecipesEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._generateRecipes(
    GenerateRecipesParams(
      instructions: event.instructions,
      kitchenId: event.kitchenId,
    ),
  );

  await res.fold(
    (failure) async {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
        ),
      );
    },
    (recipes) async {
      await RecipeLimitService.incrementUsage();

      emit(bloc.state.copyWith(recipes: recipes, isLoading: false));
    },
  );
}

Future<void> _onAddToFavouriteRecipe(
  PlannerBloc bloc,
  AddToFavouriteRecipeEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isFavLoading: true));
  final res = await bloc._addToFavouriteRecipe(
    AddToFavouriteRecipeParams(
      recipeId: event.recipeId,
      kitchenId: event.kitchenId,
    ),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isFavLoading: false,
        ),
      );
    },
    (recipes) {
      bloc.add(GetFavouriteRecipesEvent(event.kitchenId));
    },
  );
}

Future<void> _onRemoveFromFavouriteRecipe(
  PlannerBloc bloc,
  RemoveFromFavouriteRecipeEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isFavLoading: true));
  final res = await bloc._removeFromFavouriteRecipe(
    RemoveFromFavouriteRecipeParams(
      recipeId: event.recipeId,
      kitchenId: event.kitchenId,
    ),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isFavLoading: false,
        ),
      );
    },
    (recipes) {
      bloc.add(GetFavouriteRecipesEvent(event.kitchenId));
    },
  );
}

Future<void> _onClearAiGeneratedRecipes(
  PlannerBloc bloc,
  ClearAiGeneratedRecipes event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(recipes: []));
}

Future<void> _onAddToWeeklyPlan(
  PlannerBloc bloc,
  AddToWeeklyPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(addingToWeeklyPlan: true));
  var plan = event.recipeEntity;
  final res = await bloc._addToWeeklyPlan(
    AddToWeeklyPlanParams(plan.copyWith(thumbnail: null)),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          addingToWeeklyPlan: false,
        ),
      );
    },
    (successMessage) async {
      if (successMessage.toLowerCase().contains("already")) {
        AppToast.show(successMessage, ToastType.error);
      } else {
        AppToast.show(successMessage, ToastType.success);
      }
      emit(bloc.state.copyWith(successMessage: successMessage));
      bloc.add(
        GetAllWeeklyPlansEvent(bloc._userCubit.state.activeKitchenId, null),
      );
    },
  );
}

Future<void> _onDeletePlan(
  PlannerBloc bloc,
  DeletePlanEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));
  final res = await bloc._deletePlan(DeletePlanParams(event.dateString));

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
        ),
      );
    },
    (successMessage) async {
      bloc.add(
        GetAllWeeklyPlansEvent(bloc._userCubit.state.activeKitchenId, null),
      );
      await Future<void>.delayed(Duration(milliseconds: 300));
      bloc.add(GetDateBasedPlans(event.dateString));
      AppToast.show(successMessage, ToastType.success);
    },
  );
}
