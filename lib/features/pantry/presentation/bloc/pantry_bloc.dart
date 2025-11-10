import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/create_pantry_usecase.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_pantry.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_pantry_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/request_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/show_notification.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final HomeBloc _homeBloc;
  final UserCubit _userCubit;
  final GroceryBloc _groceryBloc;
  final AddPantryItem _addPantryItem;
  final GetPantryItems _getPantryItems;
  final ScanReceiptUseCase _scanReceiptUseCase;
  final RequestItems _requestItems;
  final ShowNotification _showNotification;
  final CreatePantryUsecase _createPantry;
  final DeletePantry _deletePantry;

  PantryBloc({
    required HomeBloc homeBloc,
    required UserCubit userCubit,
    required GroceryBloc groceryBloc,
    required AddPantryItem addPantryItem,
    required GetPantryItems getPantryItems,
    required ScanReceiptUseCase scanReceipt,
    required RequestItems requestItems,
    required ShowNotification showNotification,
    required CreatePantryUsecase createPantryUsecase,

    required DeletePantry deletePantry,
  }) : _addPantryItem = addPantryItem,
       _getPantryItems = getPantryItems,
       _scanReceiptUseCase = scanReceipt,
       _homeBloc = homeBloc,
       _groceryBloc = groceryBloc,
       _requestItems = requestItems,
       _showNotification = showNotification,
       _createPantry = createPantryUsecase,
       _userCubit = userCubit,
       _deletePantry = deletePantry,

       super(PantryInitial()) {
    on<PantryAddItemEvent>(_onAddPantryItem);
    on<GetPantryItemsEvent>(_onGetPantryItems);
    on<ScanReceiptEvent>(_onScanReceipt);
    on<PantryRequestItemEvent>(_onRequestItems);
    on<IncrementItemEvent>(_onIncrementItem);
    on<DecrementItemEvent>(_onDecrementItem);
    on<ShowNotificationEvent>(_onShowNotificationEvent);
    on<CreatePantryEvent>(_onCreatePantry);
    on<GetUserStorageAreaForPantryViewEvent>(
      _onGetUserStorageAreaForPantryView,
    );
    on<DeletePantryEvent>(_onDeletePantry);
  }

  Future<void> _onAddPantryItem(
    PantryAddItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());
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
    emit(PantryLoading());
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
    emit(PantryLoading());
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
    emit(PantryLoading());
    final res = await _requestItems(RequestItemsParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (message) {
      emit(PantrySuccess(message));
      add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));
      _groceryBloc.add(
        RequestedGroceryEvent(kitchenId: event.pantry.kitchenId),
      );
    });
  }

  void _onIncrementItem(IncrementItemEvent event, Emitter<PantryState> emit) {
    if (state is ScanReceiptLoaded) {
      var currentState = state as ScanReceiptLoaded;
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

  void _onDecrementItem(DecrementItemEvent event, Emitter<PantryState> emit) {
    if (state is ScanReceiptLoaded) {
      var currentState = state as ScanReceiptLoaded;
      final updatedItems = List<ScanReceiptItemEntity>.from(
        currentState.scanReceipt.items,
      );

      final item = updatedItems[event.index] as ScanReceiptItemModel;
      String amount = (int.parse(item.amount) - 1).toString();
      updatedItems[event.index] = item.copyWith(amount: amount);

      emit(
        currentState.copyWith(
          scanReceipt: ScanReceiptEntity(
            successMessage: "",
            items: updatedItems,
          ),
        ),
      );
    }
  }

  void _onShowNotificationEvent(
    ShowNotificationEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _showNotification(
      ShowNotificationParams(
        id: event.id,
        title: event.title,
        body: event.body,
        payload: event.payload,
      ),
    );

    res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        AppToast.show(successMessage, ToastType.success);
      },
    );
  }

  Future<void> _onCreatePantry(
    CreatePantryEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());

    final res = await _createPantry(
      CreatePantryUsecaseParams(
        kitchenId: event.kitchenId,
        pantries: event.pantries,
      ),
    );

    res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        emit(PantrySuccess(successMessage));
      },
    );
  }

  Future<void> _onGetUserStorageAreaForPantryView(
    GetUserStorageAreaForPantryViewEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());
    await _userCubit.getUserStorageArea(kitchenId: event.kitchenId);
    emit(UserStorageAreaLoaded(_userCubit.state.userStorageAreas));
  }

  Future<void> _onDeletePantry(
    DeletePantryEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());

    final res = await _deletePantry(
      DeletePantryParams(kitchenId: event.kitchenId, pantryId: event.pantryId),
    );

    res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        emit(PantrySuccess(successMessage));
      },
    );
  }
}
