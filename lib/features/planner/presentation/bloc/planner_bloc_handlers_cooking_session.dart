part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onMarkRecipeFinished(
  PlannerBloc bloc,
  MarkRecipeFinishedEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isFinishingRecipe: true, isRecipeFinished: false));
  final res = await bloc._markRecipeFinished(
    MarkRecipeFinishedParams(
      kitchenId: event.kitchenId,
      recipeId: event.recipeId,
    ),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isFinishingRecipe: false,
          startRecipe: false,
          isRecipeFinished: false,
        ),
      );
    },
    (successMessage) async {
      emit(
        bloc.state.copyWith(
          isFinishingRecipe: false,
          startRecipe: false,
          isRecipeFinished: true,
        ),
      );
      emit(bloc.state.copyWith(isRecipeFinished: false));
      bloc._homeBloc.add(
        GetPantriesItemsEventForHome(kitchenId: event.kitchenId),
      );
      AppToast.show(
        successMessage,
        ToastType.success,
        timeInSecForIosWeb: 4,
        gravity: ToastGravity.TOP,
      );
    },
  );
}

Future<void> _onCancelInProgressRecipe(
  PlannerBloc bloc,
  CancelInProgressRecipeEvent event,
  Emitter<PlannerState> emit,
) async {
  final updatedRecipes = List<RecipeModel>.from(bloc.state.startedRecipe);
  final updatedDoneSteps = List<List<Map<String, dynamic>>>.from(
    bloc.state.doneSteps,
  );
  if (event.inProgressRecipeIndex >= 0 &&
      event.inProgressRecipeIndex < updatedRecipes.length) {
    updatedRecipes.removeAt(event.inProgressRecipeIndex);
    updatedDoneSteps.removeAt(event.inProgressRecipeIndex);
  }
  emit(
    bloc.state.copyWith(
      startedRecipe: updatedRecipes,
      doneSteps: updatedDoneSteps,
    ),
  );

  bloc._userCubit.updateRecipeEntity(updatedRecipes);
}

Future<void> _onUpdateStartRecipe(
  PlannerBloc bloc,
  UpdateStartRecipeEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(startRecipe: event.startRecipe));
  if (event.startRecipe) {
    emit(
      bloc.state.copyWith(
        startedRecipe: event.recipeEntity,
        doneSteps: [...bloc.state.doneSteps, event.doneSteps],
      ),
    );
    bloc._userCubit.updateRecipeEntity(event.recipeEntity);
  } else {
    emit(bloc.state.copyWith(startedRecipe: [], doneSteps: []));
    bloc._userCubit.updateRecipeEntity([]);
  }
}

Future<void> _onResetPlanner(
  PlannerBloc bloc,
  ResetPlannerStateEvent event,
  Emitter<PlannerState> emit,
) async {}
