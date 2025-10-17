import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_pantry_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/request_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final HomeBloc _homeBloc;
  final GroceryBloc _groceryBloc;
  final AddPantryItem _addPantryItem;
  final GetPantryItems _getPantryItems;
  final ScanReceiptUseCase _scanReceiptUseCase;
  final RequestItems _requestItems;

  PantryBloc({
    required HomeBloc homeBloc,
    required GroceryBloc groceryBloc,
    required AddPantryItem addPantryItem,
    required GetPantryItems getPantryItems,
    required ScanReceiptUseCase scanReceipt,
    required RequestItems requestItems,
  }) : _addPantryItem = addPantryItem,
       _getPantryItems = getPantryItems,
       _scanReceiptUseCase = scanReceipt,
       _homeBloc = homeBloc,
       _groceryBloc = groceryBloc,
       _requestItems = requestItems,
       super(PantryInitial()) {
    on<PantryEvent>((_, emit) => emit(PantryLoading()));
    on<PantryAddItemEvent>(_onAddPantryItem);
    on<GetPantryItemsEvent>(_onGetPantryItems);
    on<ScanReceiptEvent>(_onScanReceipt);
    on<PantryRequestItemEvent>(_onRequestItems);
  }

  Future<void> _onAddPantryItem(
    PantryAddItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _addPantryItem(AddPantryItemParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (message) {
      emit(PantrySuccess(message));
      add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));
      _homeBloc.add(
        GetPantriesItemsEventForHome(kitchenId: event.pantry.kitchenId),
      );
    });
  }

  Future<void> _onGetPantryItems(
    GetPantryItemsEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _getPantryItems(
      GetPantryItemsParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(PantryFailure(failure.message)), (pantries) {
      emit(PantryLoaded(pantries));
    });
  }

  Future<void> _onScanReceipt(
    ScanReceiptEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _scanReceiptUseCase(
      ScanReceiptUseCaseParams(filePath: event.filePath),
    );

    res.fold((failure) => emit(PantryFailure(failure.message)), (
      receiptDetails,
    ) {
      emit(ScanReceiptLoaded(receiptDetails));
    });
  }

  Future<void> _onRequestItems(
    PantryRequestItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _requestItems(RequestItemsParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (message) {
      emit(PantrySuccess(message));
      add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));
      _groceryBloc.add(
        RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
      );
    });
  }
}
