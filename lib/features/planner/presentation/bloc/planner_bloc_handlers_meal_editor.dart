part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onAddMealPlan(
  PlannerBloc bloc,
  AddMealPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  if (bloc.state.mealPlans.isNotEmpty) {
    var plans = MergedMealPlanModel.fromEntity(bloc.state.mealPlans[0]);

    switch (event.mealPlan.mealType.toLowerCase()) {
      case "breakfast":
        plans = plans.copyWith(
          breakfast: event.mealPlan,
          lunch: plans.lunch,
          dinner: plans.dinner,
          date: plans.date,
        );
      case "lunch":
        plans = plans.copyWith(
          lunch: event.mealPlan,
          breakfast: plans.breakfast,
          dinner: plans.dinner,
          date: plans.date,
        );
      case "dinner":
        plans = plans.copyWith(
          dinner: event.mealPlan,
          breakfast: plans.breakfast,
          lunch: plans.lunch,
          date: plans.date,
        );
      default:
    }
    emit(bloc.state.copyWith(mealPlans: [plans], isLoading: false));
  } else {
    var plans = MergedMealPlanModel.fromEntity(
      MergedRecipePlanEntity(date: event.date),
    );

    switch (event.mealPlan.mealType.toLowerCase()) {
      case "breakfast":
        plans = plans.copyWith(
          date: event.date,
          breakfast: event.mealPlan,
          lunch: null,
          dinner: null,
        );

      case "lunch":
        plans = plans.copyWith(
          date: event.date,
          breakfast: null,
          lunch: event.mealPlan,
          dinner: null,
        );

      case "dinner":
        plans = plans.copyWith(
          date: event.date,
          breakfast: null,
          lunch: null,
          dinner: event.mealPlan,
        );

      default:
        devLog('Unknown meal type received: ${event.mealPlan.mealType}');
    }

    devLog('   - Breakfast: ${plans.breakfast != null}');
    devLog('   - Lunch: ${plans.lunch != null}');
    devLog('   - Dinner: ${plans.dinner != null}');
    devLog('   - Plan details: $plans');

    emit(bloc.state.copyWith(mealPlans: [plans], isLoading: false));
  }
}

Future<void> _onResetMealPlanState(
  PlannerBloc bloc,
  ResetMealPlanState event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(mealPlans: []));
}

Future<void> _onDeleteMealPlan(
  PlannerBloc bloc,
  DeleteMealPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  if (bloc.state.mealPlans.isNotEmpty) {
    var plans = MergedMealPlanModel.fromEntity(bloc.state.mealPlans[0]);

    switch (event.mealType.toLowerCase()) {
      case "breakfast":
        plans = plans.copyWith(
          lunch: plans.lunch,
          breakfast: null,
          dinner: plans.dinner,
          date: plans.date,
        );
      case "lunch":
        plans = plans.copyWith(
          lunch: null,
          breakfast: plans.breakfast,
          dinner: plans.dinner,
          date: plans.date,
        );
      case "dinner":
        plans = plans.copyWith(
          lunch: plans.lunch,
          breakfast: plans.breakfast,
          dinner: null,
          date: plans.date,
        );
      default:
    }
    emit(bloc.state.copyWith(mealPlans: [plans], isLoading: false));
  }
}

Future<void> _onGetDateBasedPlans(
  PlannerBloc bloc,
  GetDateBasedPlans event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final allPlans = bloc.state.getAllWeeklyPlans;
  devLog("datebase bloc: $allPlans");
  List<MergedRecipePlanEntity> dateBasedPlan = allPlans.where((plan) {
    final planDate = formatDateToMeetBackendDate(
      formatStringDateToMeetBackendDate(plan.date),
    );
    devLog("ppppp: $planDate==${event.dateString}");
    return planDate == event.dateString;
  }).toList();

  emit(
    bloc.state.copyWith(
      startDate: bloc.state.startDate,
      dateBasedPlan: dateBasedPlan.isNotEmpty ? [dateBasedPlan[0]] : [],
      isLoading: false,
      addingToWeeklyPlan: false,
    ),
  );
}

Future<void> _onDeleteMealTypeFromWeeklyPlan(
  PlannerBloc bloc,
  DeleteMealTypeFromWeeklyPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));
  final res = await bloc._deleteMealTypeFromWeeklyPlan(
    DeleteMealTypeFromWeeklyPlanParams(
      selectedDate: event.selectedDate,
      mealType: event.mealType,
    ),
  );

  res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(errorMessage: failure.userMessage, isLoading: false),
      );
    },
    (getAllWeeklyPlans) async {
      List<MergedRecipePlanEntity> mergedMealPlanEntities =
          mergeMealPlansByDate(getAllWeeklyPlans);
      bloc.add(GetDateBasedPlans(event.selectedDate));
      emit(
        bloc.state.copyWith(
          getAllWeeklyPlans: mergedMealPlanEntities,
          isLoading: false,
        ),
      );
    },
  );
}
