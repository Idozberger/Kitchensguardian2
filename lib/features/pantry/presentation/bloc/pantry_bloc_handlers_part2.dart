part of 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';

Future<void> _onShowNotificationEvent(
  PantryBloc bloc,
  ShowNotificationEvent event,
  Emitter<PantryState> emit,
) async {
  final res = await bloc._showNotification(
    ShowNotificationParams(
      id: event.id,
      title: event.title,
      body: event.body,
      payload: event.payload,
    ),
  );

  res.fold(
    (failure) {
      AppToast.show(failure.userMessage, ToastType.error);
    },
    (successMessage) {
      AppToast.show(successMessage, ToastType.success);
    },
  );
}

Future<void> _onCreatePantry(
  PantryBloc bloc,
  CreatePantryEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());

  final res = await bloc._createPantry(
    CreatePantryUsecaseParams(
      kitchenId: event.kitchenId,
      pantries: event.pantries,
    ),
  );

  await res.fold(
    (failure) {
      AppToast.show(failure.userMessage, ToastType.error);
    },
    (successMessage) async {
      await bloc._userCubit.getUserStorageArea(kitchenId: event.kitchenId);
      emit(PantrySuccess(successMessage));
    },
  );
}

Future<void> _onGetUserStorageAreaForPantryView(
  PantryBloc bloc,
  GetUserStorageAreaForPantryViewEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());
  await bloc._userCubit.getUserStorageArea(kitchenId: event.kitchenId);
  emit(UserStorageAreaLoaded(bloc._userCubit.state.userStorageAreas));
}

Future<void> _onDeletePantry(
  PantryBloc bloc,
  DeletePantryEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());

  final res = await bloc._deletePantry(
    DeletePantryParams(kitchenId: event.kitchenId, pantryId: event.pantryId),
  );

  res.fold(
    (failure) {
      bloc.add(GetUserStorageAreaForPantryViewEvent(event.kitchenId));
    },
    (successMessage) {
      emit(PantrySuccess(successMessage));
    },
  );
}

Future<void> _onCartItem(
  PantryBloc bloc,
  CartItemsEvent event,
  Emitter<PantryState> emit,
) async {
  final currentState = bloc.state;

  if (currentState is PantryLoaded) {
    final index = event.index;

    emit(currentState.copyWith(loadingIndex: index, isToCart: true));

    final res = await bloc._cartItems(CartItemsParams(pantry: event.pantry));

    res.fold(
      (failure) {
        AppToast.show(failure.userMessage, ToastType.error);
        emit(
          currentState.copyWith(
            loadingIndex: null,
            errorMessage: failure.userMessage,
            isToCart: false,
          ),
        );
      },
      (successMessage) {
        AppToast.show(successMessage, ToastType.success);
        emit(
          currentState.copyWith(
            loadingIndex: null,
            successMessage: successMessage,
            isToCart: false,
          ),
        );
        bloc._groceryBloc
          ..add(
            RequestedGroceryEvent(
              kitchenId: bloc._userCubit.state.activeKitchenId,
            ),
          )
          ..add(
            GetAiGeneratedItemsEvent(
              kitchenId: bloc._userCubit.state.activeKitchenId,
            ),
          );
      },
    );
  }
}

Future<void> _onDeleteItem(
  PantryBloc bloc,
  DeleteItemEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());

  final res = await bloc._deleteItem(DeleteItemParams(pantry: event.pantry));

  res.fold(
    (failure) {
      AppToast.show(failure.userMessage, ToastType.error);
    },
    (successMessage) {
      emit(PantrySuccess(successMessage));
      bloc.add(
        GetPantryItemsEvent(kitchenId: bloc._userCubit.state.activeKitchenId),
      );
      bloc._homeBloc.add(
        GetPantriesItemsEventForHome(
          kitchenId: bloc._userCubit.state.activeKitchenId,
        ),
      );
    },
  );
}

Future<void> _onUpdateItem(
  PantryBloc bloc,
  UpdateItemEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());
  final res = await bloc._updateItem(UpdateItemParams(pantry: event.pantry));

  res.fold(
    (failure) {
      AppToast.show(failure.userMessage, ToastType.error);
    },
    (successMessage) {
      emit(PantrySuccess(successMessage));
      bloc.add(
        GetPantryItemsEvent(kitchenId: bloc._userCubit.state.activeKitchenId),
      );
      bloc._homeBloc.add(
        GetPantriesItemsEventForHome(
          kitchenId: bloc._userCubit.state.activeKitchenId,
        ),
      );
    },
  );
}
