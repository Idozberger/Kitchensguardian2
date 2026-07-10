part of 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';

Future<void> _onGetAllMealPlans(
  PlannerBloc bloc,
  GetAllWeeklyPlansEvent event,
  Emitter<PlannerState> emit,
) async {
  if (event.kitchenId.isEmpty) return;

  emit(bloc.state.copyWith(loadingPlans: true));

  final res = await bloc._getAllPlans(
    GetAllPlansParams(kitchenId: event.kitchenId),
  );

  await res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          loadingPlans: false,
        ),
      );
    },
    (getAllWeeklyPlans) async {
      final mergedMealPlanEntities = mergeMealPlansByDate(getAllWeeklyPlans);

      emit(
        bloc.state.copyWith(
          getAllWeeklyPlans: mergedMealPlanEntities,
          loadingPlans: false,
        ),
      );

      if (getAllWeeklyPlans.isNotEmpty) {
        await NotificationService()
            .scheduleMealPlanReminders(mergedMealPlanEntities, {
              "kitchenId": event.kitchenId,
              "invitationCode": bloc._userCubit.state.invitationCode,
              "kitchenName": bloc._userCubit.state.kitchenName,
              "role": bloc._userCubit.state.role,
            });
      }
      devLog(
        "plan: ${bloc.state.startDate} || ${PlannerDateFormatter.toBackendFormat(DateTime.now())}",
      );
      bloc.add(
        GetDateBasedPlans(
          bloc.state.startDate ??
              PlannerDateFormatter.toBackendFormat(DateTime.now()),
        ),
      );
    },
  );
}

Future<void> _onGetMealByDate(
  PlannerBloc bloc,
  GetMealByDateEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._getMealByDate(
    GetMealByDateParams(date: event.date, kitchenId: event.kitchenId),
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
    (successMessage) {
      emit(
        bloc.state.copyWith(successMessage: successMessage, isLoading: false),
      );
    },
  );
}

Future<void> _onUpdateMealPlan(
  PlannerBloc bloc,
  UpdateMealPlanEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._updateMealPlan(
    UpdateMealPlanParams(
      mealPlanId: event.mealPlanId,
      mealType: event.mealType,
      notes: event.notes,
      recipeId: event.recipeId,
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
    (successMessage) {
      emit(
        bloc.state.copyWith(successMessage: successMessage, isLoading: false),
      );
    },
  );
}

Future<void> _onDeletePlanFromRemoteDb(
  PlannerBloc bloc,
  DeletePlanFromRemoteDbEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true, loadingPlans: true));

  final res = await bloc._deletePlanRemoteDb(
    DeletePlanRemoteDbParams(
      mealPlanId: event.mealPlanId,
      kitchenId: event.kitchenId ?? "",
      date: event.date ?? "",
    ),
  );

  await res.fold(
    (failure) async {
      Future.microtask(() {
        bloc.add(
          GetAllWeeklyPlansEvent(
            bloc._userCubit.state.activeKitchenId,
            event.date,
          ),
        );
      });

      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
          loadingPlans: false,
        ),
      );
    },
    (successMessage) async {
      await Future<void>.delayed(const Duration(seconds: 4));
      Future.microtask(() {
        bloc.add(
          GetAllWeeklyPlansEvent(
            bloc._userCubit.state.activeKitchenId,
            event.date,
          ),
        );
      });
      bloc._homeBloc.add(GetAllWeeklyPlansEventForHome());
      emit(
        bloc.state.copyWith(
          successMessage: successMessage,
          isLoading: false,
          loadingPlans: false,
        ),
      );
    },
  );
}

Future<void> _onCreatePlan(
  PlannerBloc bloc,
  CreatePlanEvent event,
  Emitter<PlannerState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final res = await bloc._createPlan(CreatePlanParams(event.mealPlans));

  await res.fold(
    (failure) async {
      await Future<void>.delayed(const Duration(seconds: 4));
      bloc.add(
        GetAllWeeklyPlansEvent(bloc._userCubit.state.activeKitchenId, null),
      );

      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          isLoading: false,
        ),
      );
    },
    (successMessage) async {
      if (bloc.state.startDate == null || bloc.state.startDate!.isEmpty) {
        bloc.updateStartEndDate();
      }

      await Future<void>.delayed(const Duration(seconds: 4));
      bloc.add(
        GetAllWeeklyPlansEvent(bloc._userCubit.state.activeKitchenId, null),
      );
      bloc._homeBloc.add(GetAllWeeklyPlansEventForHome());

      emit(
        bloc.state.copyWith(successMessage: successMessage, isLoading: false),
      );
    },
  );
}
