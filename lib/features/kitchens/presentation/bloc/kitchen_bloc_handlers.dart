part of 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';

Future<void> _onMemberApproved(
  KitchenBloc bloc,
  MemberApprovedEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());

  final res = await bloc._joinKitchen(
    JoinKitchenUsecaseParams(
      invitationCode: event.invitationCode,
      userId: event.userId,
    ),
  );

  res.fold(
    (failure) => emit(KitchenFailure(failure.userMessage)),
    (message) => emit(KitchenSuccess(message)),
  );
  bloc.add(FetchKitchens());
}

Future<void> _onFetchKitchens(
  KitchenBloc bloc,
  FetchKitchens event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());

  final res = await bloc._getKitchens(NoParams());
  res.fold((failure) => emit(KitchenFailure(failure.userMessage)), (kitchens) {
    emit(KitchensLoaded(kitchens));
  });
}

Future<void> _onCreateKitchenEvent(
  KitchenBloc bloc,
  CreateKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());
  final res = await bloc._createKitchen(
    CreateKitchenParams(
      kitchenName: event.kitchenName,
      unitSystem: event.unitSystem,
    ),
  );

  res.fold((failure) => emit(KitchenFailure(failure.userMessage)), (message) {
    emit(KitchenSuccess(message));
  });
}

Future<void> _onJoinKitchenEvent(
  KitchenBloc bloc,
  JoinKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());

  final sender = bloc._userCubit.state;
  final outcome = await bloc._submitKitchenJoinRequest(
    SubmitKitchenJoinRequestParams(
      invitationCode: event.invitationCode,
      senderUserId: sender.userId,
      senderFirstName: sender.firstName,
      senderLastName: sender.lastName,
      checkPendingDuplicate: true,
      fcmMetadataFromHostKitchen: true,
      fcmInvitationCode: '',
      fcmKitchenName: '',
      fcmRole: '',
      fcmKitchenId: '',
      includeApprovedByFieldInNotification: true,
    ),
  );

  switch (outcome) {
    case KitchenJoinInvalidInvitation():
      emit(KitchenFailure("Invitation code is not valid"));
    case KitchenJoinSenderIsHost(:final kitchenName):
      AppToast.show(
        "You are the host of this kitchen: $kitchenName. You already have access.",
        ToastType.error,
      );
      bloc.add(FetchKitchens());
    case KitchenJoinHostUserNotFound():
      emit(KitchenFailure("Kitchen host not found"));
    case KitchenJoinPendingAlreadyExists(:final kitchenName):
      AppToast.show(
        "Your request to join \"$kitchenName\" is already pending",
        ToastType.error,
      );
      bloc.add(FetchKitchens());
    case KitchenJoinHostDeviceTokenMissing():
      emit(KitchenFailure("User not found"));
    case KitchenJoinRequestSent():
      AppToast.show("Kitchen join request sent", ToastType.success);
      bloc.add(FetchKitchens());
    case KitchenJoinUnexpectedError():
      emit(KitchenFailure("An error accured"));
  }
}

Future<void> _onLeaveKitchen(
  KitchenBloc bloc,
  LeaveKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());
  final res = await bloc._leaveKitchenUsecase(
    LeaveKitchenParams(kitchenId: event.kitchenId),
  );

  res.fold((failure) => emit(KitchenFailure(failure.userMessage)), (message) {
    bloc.add(DeleteOrLeaveKitchenEvent());
    emit(KitchenSuccess(message));
  });
}

Future<void> _onRemoveKitchen(
  KitchenBloc bloc,
  RemoveKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());
  final res = await bloc._removeKitchenUsecase(
    RemoveKitchenParams(kitchenId: event.kitchenId),
  );

  res.fold((failure) => emit(KitchenFailure(failure.userMessage)), (message) {
    bloc.add(DeleteOrLeaveKitchenEvent());
    emit(KitchenSuccess(message));
  });
}

Future<void> _onSwitchKitchen(
  KitchenBloc bloc,
  SwitchKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());
  final kitchenId = event.kitchen.kitchenId;
  if (event.kitchen.invitationCode.isNotEmpty) {
    await bloc._saveOrUpdateUserKitchen(kitchen: event.kitchen);
  }
  bloc._plannerBloc.add(GetDateRangeEvent(kitchenId: kitchenId));
  bloc._plannerBloc.add(GetAllWeeklyPlansEvent(kitchenId, null));
  bloc._homeBloc.add(GetAllWeeklyPlansEventForHome());
  bloc._homeBloc.add(GetUserStorageAreaEvent(kitchenId));
  bloc._homeBloc.add(GetRecipeSuggestionEvent(kitchenId));
  bloc._homeBloc.add(GetPantriesItemsEventForHome(kitchenId: kitchenId));
  bloc._homeBloc.add(GetAllRequestedItemsEvent(kitchenId: kitchenId));
  bloc._groceryBloc.add(RequestedGroceryEvent(kitchenId: kitchenId));
  await bloc._userCubit.getUserStorageArea(kitchenId: kitchenId);

  bloc._homeBloc.add(GenerateGroceryList());
  emit(OpenKitchen());
}

Future<void> _onDeleteOrLeaveKitchen(
  KitchenBloc bloc,
  DeleteOrLeaveKitchenEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(KitchensLoading());
  bloc._userCubit.updateKitchenIdAndRefferalCode("", "");
  bloc._homeBloc.add(ResetHomeStateEvent());
  bloc._groceryBloc.add(ResetGroceryStateEvent());
  bloc._plannerBloc.add(ResetPlannerStateEvent());

  bloc.add(FetchKitchens());
}

Future<void> _onInviteUser(
  KitchenBloc bloc,
  InviteUserEvent event,
  Emitter<KitchenState> emit,
) async {
  emit(
    (bloc.state as AllUserLoaded).copyWith(isLoading: true, index: event.index),
  );

  final res = await bloc._inviteUser(
    InviteUserKitchenParams(kitchenId: event.kitchenId, email: event.email),
  );

  res.fold(
    (failure) {
      emit(
        (bloc.state as AllUserLoaded).copyWith(
          isLoading: false,
          index: -1,
          errorMessage: failure.userMessage,
        ),
      );
    },
    (successMessage) {
      emit(
        (bloc.state as AllUserLoaded).copyWith(
          isLoading: false,
          index: -1,
          successMessage: successMessage,
        ),
      );
    },
  );
}

Future<void> _onFetchAllUsers(
  KitchenBloc bloc,
  FetchAllUsers event,
  Emitter<KitchenState> emit,
) async {
  emit(AllUserLoaded(isLoading: true));
  await Future<void>.delayed(Duration(seconds: 3));
  emit(AllUserLoaded(isLoading: false));
}
