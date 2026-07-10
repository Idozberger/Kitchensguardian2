part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onCheckMissingIngredientsEvent(
  PlannerBloc bloc,
  CheckMissingIngredientsEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(
    bloc.state.copyWith(
      isCheckingMissingIngredients: true,
      hasMissingIngredients: false,
    ),
  );
  final res = await bloc._checkMissingIngredients(
    CheckMissingIngredientsParams(
      kitchenId: event.kitchenId,
      recipeId: event.recipeId,
    ),
  );

  res.fold(
    (failure) {
      devLog("hasMissingIngredients: Error ${failure.userMessage}");
      emit(
        bloc.state.copyWith(
          isCheckingMissingIngredients: false,
          hasMissingIngredients: false,
        ),
      );
    },
    (hasMissingIngredients) {
      devLog("hasMissingIngredients: $hasMissingIngredients");
      emit(
        bloc.state.copyWith(
          isCheckingMissingIngredients: false,
          hasMissingIngredients: hasMissingIngredients,
        ),
      );
    },
  );
}

Future<void> _onSetDateRange(
  PlannerBloc bloc,
  SetDateRangeEvent event,
  Emitter<PlannerState> emit,
) async {
  if (bloc._userCubit.state.activeKitchenId.isEmpty) return;
  final res = await bloc._setDateRange(
    SetDateRangeParams(
      kitchenId: bloc._userCubit.state.activeKitchenId,
      startDate: event.startDate,
      endDate: event.endDate,
    ),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
        ),
      );
    },
    (dateRange) {
      devLog(
        "Date Ranges: ${dateRange.startDate} -- End Date ${dateRange.endDate}",
      );
      emit(
        bloc.state.copyWith(
          endDate: dateRange.endDate,
          startDate: dateRange.startDate,
        ),
      );
    },
  );
  emit(bloc.state.copyWith(isLoading: true));
}

Future<void> _onGetDateRangeEvent(
  PlannerBloc bloc,
  GetDateRangeEvent event,
  Emitter<PlannerState> emit,
) async {
  if (event.kitchenId.isEmpty) return;
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._getDateRange(GetDateRangeParams(event.kitchenId));

  await res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
        ),
      );
    },
    (dateRange) async {
      if (dateRange.endDate.isNotEmpty) {
        final existingEndDate = formatStringDateToMeetBackendDate(
          dateRange.endDate,
        );
        final todayOnly = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );

        if (existingEndDate.isBefore(todayOnly)) {
          queueDefaultPlannerDateRange(
            userCubit: bloc._userCubit,
            enqueue: bloc.add,
          );
          bloc.add(
            GetDateRangeEvent(kitchenId: bloc._userCubit.state.activeKitchenId),
          );
        }
      }
      emit(
        bloc.state.copyWith(
          endDate: dateRange.endDate,
          startDate: dateRange.startDate,
          isLoading: false,
        ),
      );
    },
  );
}

Future<void> _onEditMeal(
  PlannerBloc bloc,
  EditMealEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(editMealsPlans: [event.mergedPlans]));
}
