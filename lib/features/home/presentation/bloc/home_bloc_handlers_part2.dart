part of 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';

Future<void> _onJoinKitchenEvent(
  HomeBloc bloc,
  JoinKitchenEventForHome event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));

  final sender = bloc._userCubit.state;
  final outcome = await bloc._submitKitchenJoinRequest(
    SubmitKitchenJoinRequestParams(
      invitationCode: event.invitationCode,
      senderUserId: sender.userId,
      senderFirstName: sender.firstName,
      senderLastName: sender.lastName,
      checkPendingDuplicate: false,
      fcmMetadataFromHostKitchen: false,
      fcmInvitationCode: sender.invitationCode,
      fcmKitchenName: sender.kitchenName,
      fcmRole: sender.role,
      fcmKitchenId: sender.activeKitchenId,
      includeApprovedByFieldInNotification: false,
    ),
  );

  switch (outcome) {
    case KitchenJoinInvalidInvitation():
      emit(
        bloc.state.copyWith(
          isLoading: false,
          errorMessage: "Invitation code is not valid",
        ),
      );
    case KitchenJoinSenderIsHost(:final kitchenName):
      AppToast.show(
        "You are the host of this kitchen: $kitchenName. You already have access.",
        ToastType.error,
      );
      bloc.add(GetPantriesItemsEventForHome(kitchenId: sender.activeKitchenId));
      emit(bloc.state.copyWith(isLoading: false));
    case KitchenJoinHostUserNotFound():
      emit(
        bloc.state.copyWith(
          isLoading: false,
          errorMessage: "Kitchen host not found",
        ),
      );
    case KitchenJoinPendingAlreadyExists():
      emit(
        bloc.state.copyWith(
          isLoading: false,
          errorMessage: 'An error occurred.',
        ),
      );
    case KitchenJoinHostDeviceTokenMissing():
      emit(
        bloc.state.copyWith(isLoading: false, errorMessage: "User not found"),
      );
    case KitchenJoinRequestSent():
      bloc.add(GetPantriesItemsEventForHome(kitchenId: sender.activeKitchenId));
      emit(
        bloc.state.copyWith(
          isLoading: false,
          successMessage: "Join request sent to the host.",
        ),
      );
    case KitchenJoinUnexpectedError():
      emit(
        bloc.state.copyWith(
          isLoading: false,
          errorMessage: 'An error occurred.',
        ),
      );
  }
}

Future<void> _onGetPantryItems(
  HomeBloc bloc,
  GetPantriesItemsEventForHome event,
  Emitter<HomeState> emit,
) async {
  emit(bloc.state.copyWith(isLoading: true));
  final res = await bloc._getPantriesForHome(
    GetPantriesForHomeParams(kitchenId: event.kitchenId),
  );

  res.fold(
    (failure) => emit(
      bloc.state.copyWith(isLoading: false, errorMessage: failure.userMessage),
    ),
    (pantries) async {
      final List<PantriesItemsEntity> pantryItems = [];
      final List<PantriesItemsEntity> lowStockItems = [];
      final List<PantriesItemsEntity> expiringItems = [];

      for (final item in pantries.items) {
        if (item.stockStatus == "low_stock") {
          lowStockItems.add(item);
          continue;
        }

        if (item.expiryStatus == "expiring_soon") {
          expiringItems.add(item);

          continue;
        }

        if (item.stockStatus == "in_stock" ||
            item.expiryStatus == "" ||
            item.expiryStatus == "null") {
          pantryItems.add(item);
          continue;
        }

        pantryItems.add(item);
      }

      emit(
        bloc.state.copyWith(
          isLoading: false,
          pantryItems: [pantries],
          lowStockItems: lowStockItems,
          expiringItems: expiringItems,
        ),
      );

      await scheduleHomePantryNotifications(
        userCubit: bloc._userCubit,
        lowStockItems: lowStockItems,
        expiringItems: expiringItems,
      );
    },
  );
}

Future<void> _onGetUserStorageArea(
  HomeBloc bloc,
  GetUserStorageAreaEvent event,
  Emitter<HomeState> emit,
) async {
  bloc._userCubit.getUserStorageArea(kitchenId: event.kitchenId);
}

Future<void> _onGetAllWeeklyPlans(
  HomeBloc bloc,
  GetAllWeeklyPlansEventForHome event,
  Emitter<HomeState> emit,
) async {
  if (bloc._userCubit.state.activeKitchenId.isEmpty) return;
  emit(bloc.state.copyWith(loadingWeeklyPlans: true, showGroceryShimmer: true));
  final res = await bloc._getAllWeeklyPlansForHome(
    GetAllWeeklyPlansForHomeParams(bloc._userCubit.state.activeKitchenId),
  );

  await res.fold(
    (failure) {
      emit(
        bloc.state.copyWith(
          errorMessage: failure.userMessage,
          loadingWeeklyPlans: false,
        ),
      );
    },
    (getAllWeeklyPlans) async {
      emit(
        bloc.state.copyWith(
          dateBasedPlan: getAllWeeklyPlans,
          loadingWeeklyPlans: false,
        ),
      );

      bloc.add(GenerateGroceryList());
      emit(bloc.state.copyWith(showGroceryShimmer: false));
    },
  );
}

void _onResetHomeState(
  HomeBloc bloc,
  ResetHomeStateEvent event,
  Emitter<HomeState> emit,
) {
  emit(bloc.state.copyWith(pantryItems: []));
}
