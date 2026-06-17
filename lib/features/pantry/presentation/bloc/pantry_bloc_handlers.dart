part of 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';

Future<void> _addScanItemsToPantry(
  PantryBloc bloc,
  PantryAddScannedItemEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());

  final res = await bloc._addPantryItem(
    AddPantryItemParams(pantry: event.pantry),
  );

  res.fold((failure) => emit(PantryFailure(failure.userMessage)), (message) async {
    bloc._homeBloc.add(
      GetPantriesItemsEventForHome(kitchenId: event.pantry.kitchenId),
    );

    bloc.add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));

    emit(PantrySuccess(message));
  });
}

Future<void> _onAddPantryItem(
  PantryBloc bloc,
  PantryAddItemEvent event,
  Emitter<PantryState> emit,
) async {
  emit(SubmittingItemLoading());

  if (event.isMember) {
    bloc._plannerBloc.add(
      RequestMissingItemsEvent(
        pantry: event.pantry,
        selectedIngredients: [],
        recipeId: '',
        isPlan: false,
      ),
    );

    emit(PantrySuccess("Items requested successfully"));
    return;
  }

  final res = await bloc._addPantryItem(
    AddPantryItemParams(pantry: event.pantry),
  );

  res.fold((failure) => emit(PantryFailure(failure.userMessage)), (message) async {
    bloc._homeBloc.add(
      GetPantriesItemsEventForHome(kitchenId: event.pantry.kitchenId),
    );

    bloc.add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));

    bloc._homeBloc.add(
      homeEvent.GetAllRequestedItemsEvent(kitchenId: event.pantry.kitchenId),
    );

    emit(PantrySuccess(message));
  });
}

Future<void> _onGetPantryItems(
  PantryBloc bloc,
  GetPantryItemsEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());

  final res = await bloc._getPantryItems(
    GetPantryItemsParams(kitchenId: event.kitchenId),
  );

  await res.fold<Future<void>>(
    (failure) async {
      emit(PantryFailure(failure.userMessage));
    },
    (items) async {
      final partitioned = partitionPantryItemsByAlerts(items);

      emit(
        PantryLoaded(
          pantryItems: items,
          lowStockItems: partitioned.lowStock,
          expiringItems: partitioned.expiring,
        ),
      );
      await schedulePantryStockNotifications(
        userCubit: bloc._userCubit,
        lowStockItems: partitioned.lowStock,
        expiringItems: partitioned.expiring,
      );
    },
  );
}

Future<void> _onScanReceipt(
  PantryBloc bloc,
  ScanReceiptEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryScanItemsLoading());
  final res = await bloc._scanReceiptUseCase(
    ScanReceiptUseCaseParams(
      filePath: event.filePath,
      country: event.country,
      currency: event.currency,
    ),
  );

  res.fold((failure) => emit(PantryFailure(failure.userMessage)), (receiptDetails) {
    emit(ScanReceiptLoaded(receiptDetails));
  });
}

Future<void> _onRequestItems(
  PantryBloc bloc,
  PantryRequestItemEvent event,
  Emitter<PantryState> emit,
) async {
  emit(PantryLoading());
  final res = await bloc._requestItems(
    RequestItemsParams(pantry: event.pantry),
  );

  res.fold((failure) => emit(PantryFailure(failure.userMessage)), (message) {
    emit(PantrySuccess(message));
    bloc.add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));
    bloc._groceryBloc.add(
      RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
    );
  });
}

void _onIncrementItem(
  PantryBloc bloc,
  IncrementItemEvent event,
  Emitter<PantryState> emit,
) {
  if (bloc.state is ScanReceiptLoaded) {
    var currentState = bloc.state as ScanReceiptLoaded;
    final updatedItems = List<ScanReceiptItemEntity>.from(
      currentState.scanReceipt.items,
    );

    final item = updatedItems[event.index] as ScanReceiptItemModel;
    String amount = (int.parse(item.amount) + 1).toString();
    updatedItems[event.index] = item.copyWith(amount: amount);

    emit(
      currentState.copyWith(
        scanReceipt: ScanReceiptEntity(
          successMessage: "d",
          items: updatedItems,
        ),
      ),
    );
  }
}

void _onDecrementItem(
  PantryBloc bloc,
  DecrementItemEvent event,
  Emitter<PantryState> emit,
) {
  if (bloc.state is ScanReceiptLoaded) {
    var currentState = bloc.state as ScanReceiptLoaded;
    final updatedItems = List<ScanReceiptItemEntity>.from(
      currentState.scanReceipt.items,
    );

    final item = updatedItems[event.index] as ScanReceiptItemModel;
    String amount = (int.parse(item.amount) - 1).toString();
    updatedItems[event.index] = item.copyWith(amount: amount);

    emit(
      currentState.copyWith(
        scanReceipt: ScanReceiptEntity(successMessage: "", items: updatedItems),
      ),
    );
  }
}
