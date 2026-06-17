part of 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';

Future<void> _onGetRecipeDetailsEvent(
  DashboardBloc bloc,
  GetRecipeDetailsEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DashboardLoading());
  final res = await bloc._getRecipeDetails(
    GetRecipeDetailsParams(
      recipeId: event.recipeId,
      kitchenId: event.kitchenId,
    ),
  );

  res.fold(
    (failure) {
      emit(DashboardFailure(failure.userMessage));
    },
    (recipes) {
      emit(RecipeDetailsLoaded(recipes));
    },
  );
}

Future<void> _onGetDashboardMembers(
  DashboardBloc bloc,
  GetKitchenMembersEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DashboardLoading());

  final res = await bloc._getKitchenMembers(
    GetKitchenMembersParams(kitchenId: event.activeKitchenId),
  );

  res.fold((failure) => emit(DashboardFailure(failure.userMessage)), (members) {
    final currentState = bloc.state;

    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(kitchenMembers: members));
    } else {
      emit(DashboardLoaded(kitchenMembers: members));
    }
  });
}

Future<void> _onMakeCohostEvent(
  DashboardBloc bloc,
  MakeCohostEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DashboardLoading());
  final res = await bloc._makeCohost(
    MakeCohostParams(
      kitchenId: event.activeKitchenId,
      memberId: event.memberId,
    ),
  );

  res.fold((failure) => emit(DashboardFailure(failure.userMessage)), (message) {
    emit(DashboardSuccess(message));
  });
}

Future<void> _onDemoteCohostEvent(
  DashboardBloc bloc,
  DemoteCohostEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DashboardLoading());
  final res = await bloc._demoteCohost(
    DemoteCohostParams(
      kitchenId: event.activeKitchenId,
      memberId: event.memberId,
    ),
  );

  res.fold((failure) => emit(DashboardFailure(failure.userMessage)), (message) {
    emit(DashboardSuccess(message));
  });
}

Future<void> _onKickMemberEvent(
  DashboardBloc bloc,
  KickMemberEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DashboardLoading());
  final res = await bloc._kickMember(
    KickMemberParams(
      kitchenId: event.activeKitchenId,
      memberId: event.memberId,
    ),
  );

  res.fold((failure) => emit(DashboardFailure(failure.userMessage)), (message) {
    emit(DashboardSuccess(message));
  });
}

Future<void> _onApproveRequestEvent(
  DashboardBloc bloc,
  ApproveRequestEvent event,
  Emitter<DashboardState> emit,
) async {
  devLog("[approve]");
  emit(ApproveLoading(event.date));
  final host = bloc._userCubit.state;
  final result = await bloc._approveKitchenJoinRequest(
    ApproveKitchenJoinRequestParams(
      memberUserId: event.memberId,
      kitchenId: event.kitchenId,
      notificationLegacyId: event.id,
      hostUserId: host.userId,
      hostFirstName: host.firstName,
      hostLastName: host.lastName,
      hostInvitationCode: host.invitationCode,
      hostKitchenName: host.kitchenName,
      hostActiveKitchenId: host.activeKitchenId,
    ),
    onAfterFcmBeforeFirestore: (outcome) async {
      bloc._kitchenBloc.add(
        MemberApprovedEvent(
          outcome.invitationCode,
          outcome.approvedMemberUserId,
        ),
      );
    },
  );

  result.fold((failure) => emit(DashboardFailure(failure.userMessage)), (_) {
    AppToast.show("Kitchen approval notification sent", ToastType.success);
    emit(DashboardSuccess("Approved"));
  });
}

Future<void> _onDeclineRequestEvent(
  DashboardBloc bloc,
  DeclineRequestEvent event,
  Emitter<DashboardState> emit,
) async {
  emit(DeclineLoading(event.date));
  final host = bloc._userCubit.state;
  final result = await bloc._declineKitchenJoinRequest(
    DeclineKitchenJoinRequestParams(
      memberUserId: event.memberId,
      kitchenId: event.kitchenId,
      notificationLegacyId: event.id,
      hostUserId: host.userId,
      hostFirstName: host.firstName,
      hostLastName: host.lastName,
      hostInvitationCode: host.invitationCode,
      hostKitchenName: host.kitchenName,
      hostActiveKitchenId: host.activeKitchenId,
      hostRole: host.role,
    ),
  );

  result.fold((failure) => emit(DashboardFailure(failure.userMessage)), (_) {
    AppToast.show("Request Declined Successfully", ToastType.success);
    emit(DashboardSuccess("Declined"));
  });
}
