// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart'
    as homeEvent;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_request_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/cart_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/create_pantry_usecase.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/delete_pantry.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/get_pantry_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/request_items.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/show_notification.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/update_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final HomeBloc _homeBloc;
  final UserCubit _userCubit;
  final GroceryBloc _groceryBloc;
  final AddPantryItem _addPantryItem;
  final AddPantryRequestItem _addPantryRequestItem;

  final GetPantryItems _getPantryItems;
  final ScanReceiptUseCase _scanReceiptUseCase;
  final RequestItems _requestItems;
  final ShowNotification _showNotification;
  final CreatePantryUsecase _createPantry;
  final DeletePantry _deletePantry;
  final CartItems _cartItems;
  final DeleteItem _deleteItem;
  final UpdateItem _updateItem;

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
    required CartItems cartItems,
    required DeletePantry deletePantry,
    required DeleteItem deleteItem,
    required UpdateItem updateItem,
    required AddPantryRequestItem addPantryRequestItem,
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
       _cartItems = cartItems,
       _deleteItem = deleteItem,
       _updateItem = updateItem,
       _addPantryRequestItem = addPantryRequestItem,

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
    on<CartItemsEvent>(_onCartItem);
    on<DeleteItemEvent>(_onDeleteItem);
    on<UpdateItemEvent>(_onUpdateItem);
    on<PantryAddScannedItemEvent>(_addScanItemsToPantry);
  }

  Future<void> _addScanItemsToPantry(
    PantryAddScannedItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());

    final res = await _addPantryItem(AddPantryItemParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (
      message,
    ) async {
      _homeBloc.add(
        GetPantriesItemsEventForHome(kitchenId: event.pantry.kitchenId),
      );

      add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));

      emit(PantrySuccess(message));
    });
  }

  Future<void> _onAddPantryItem(
    PantryAddItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(SubmittingItemLoading());

    final res = event.isMember
        ? await _addPantryRequestItem(
            AddPantryRequestItemParams(pantry: event.pantry),
          )
        : await _addPantryItem(AddPantryItemParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (
      message,
    ) async {
      _homeBloc.add(
        GetPantriesItemsEventForHome(kitchenId: event.pantry.kitchenId),
      );

      add(GetPantryItemsEvent(kitchenId: event.pantry.kitchenId));
      _homeBloc.add(
        homeEvent.GetAllRequestedItemsEvent(kitchenId: event.pantry.kitchenId),
      );

      emit(PantrySuccess(message));
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

    await res.fold<Future<void>>(
      (failure) async {
        emit(PantryFailure(failure.message));
      },
      (items) async {
        final List<PantryItemEntity> lowStockItems = [];
        final List<PantryItemEntity> expiringItems = [];

        for (final item in items) {
          if (item.stockStatus == "low_stock") {
            lowStockItems.add(item);
            continue;
          }

          if (item.expiryStatus == "expiring_soon") {
            expiringItems.add(item);

            continue;
          }
        }

        emit(
          PantryLoaded(
            pantryItems: items,
            lowStockItems: lowStockItems,
            expiringItems: expiringItems,
          ),
        );
        await _schedulePantryNotifications(
          lowStockItems: lowStockItems,
          expiringItems: expiringItems,
        );
      },
    );
  }

  Future<void> _schedulePantryNotifications({
    required List<PantryItemEntity> lowStockItems,
    required List<PantryItemEntity> expiringItems,
  }) async {
    final notificationService = NotificationService();
    final DateTime now = DateTime.now();
    final DateTime morningTime = DateTime(now.year, now.month, now.day, 9, 0);
    final DateTime eveningTime = DateTime(now.year, now.month, now.day, 18, 0);

    // Current items' base IDs
    final currentItemIds = <int>{};
    for (final item in lowStockItems) {
      currentItemIds.add(item.itemId.hashCode & 0x7fffffff); // morning
      currentItemIds.add((item.itemId.hashCode & 0x7fffffff) + 1); // evening
    }
    for (final item in expiringItems) {
      currentItemIds.add(
        (item.itemId.hashCode & 0x7fffffff) + 100000,
      ); // morning
      currentItemIds.add(
        (item.itemId.hashCode & 0x7fffffff) + 100001,
      ); // evening
    }

    // Pending notifications
    final pendingNotifications = await notificationService
        .pendingNotifications();

    // Cancel notifications for items that no longer exist
    for (final pending in pendingNotifications) {
      if (!currentItemIds.contains(pending.id)) {
        await notificationService.cancelNotification(pending.id);
        print("Canceled obsolete notification (ID: ${pending.id})");
      }
    }

    final scheduledIds = pendingNotifications.map((e) => e.id).toSet();

    // Schedule notifications for current low stock items
    for (final item in lowStockItems) {
      final int morningId = item.itemId.hashCode & 0x7fffffff;
      final int eveningId = morningId + 1;

      if (!scheduledIds.contains(morningId)) {
        await notificationService.scheduleDaily(
          id: morningId,
          title: 'Low stock: ${item.name}',
          body:
              'You are running low on ${item.name} (${item.quantity} ${item.unit}).',
          dailyTime: morningTime,
          payload: jsonEncode({
            'type': 'low_stock',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        print(
          "Scheduled morning low stock notification for ${item.name} (ID: $morningId)",
        );
      }

      if (!scheduledIds.contains(eveningId)) {
        await notificationService.scheduleDaily(
          id: eveningId,
          title: 'Low stock: ${item.name}',
          body: 'Remember to restock ${item.name}.',
          dailyTime: eveningTime,
          payload: jsonEncode({
            'type': 'low_stock',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        print(
          "Scheduled evening low stock notification for ${item.name} (ID: $eveningId)",
        );
      }
    }

    // Schedule notifications for current expiring items
    for (final item in expiringItems) {
      final int morningId = (item.itemId.hashCode & 0x7fffffff) + 100000;
      final int eveningId = morningId + 1;

      if (!scheduledIds.contains(morningId)) {
        await notificationService.scheduleDaily(
          id: morningId,
          title: 'Expiring soon: ${item.name}',
          body: '${item.name} is expiring soon (${item.expireDate}).',
          dailyTime: morningTime,
          payload: jsonEncode({
            'type': 'expiring_soon',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        print(
          "Scheduled morning expiring notification for ${item.name} (ID: $morningId)",
        );
      }

      if (!scheduledIds.contains(eveningId)) {
        await notificationService.scheduleDaily(
          id: eveningId,
          title: 'Expiring soon: ${item.name}',
          body: 'Use ${item.name} before it expires.',
          dailyTime: eveningTime,
          payload: jsonEncode({
            'type': 'expiring_soon',
            "invitationCode": _userCubit.state.invitationCode,
            "kitchenName": _userCubit.state.kitchenName,
            "role": _userCubit.state.role,
            'kitchenId': _userCubit.state.activeKitchenId,
            'item': item.toMap(),
          }),
        );
        print(
          "Scheduled evening expiring notification for ${item.name} (ID: $eveningId)",
        );
      }
    }
  }

  Future<void> _onScanReceipt(
    ScanReceiptEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryScanItemsLoading());
    final res = await _scanReceiptUseCase(
      ScanReceiptUseCaseParams(
        filePath: event.filePath,
        country: event.country,
        currency: event.currency,
      ),
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

    await res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) async {
        await _userCubit.getUserStorageArea(kitchenId: event.kitchenId);
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
        add(GetUserStorageAreaForPantryViewEvent(event.kitchenId));
      },
      (successMessage) {
        emit(PantrySuccess(successMessage));
      },
    );
  }

  Future<void> _onCartItem(
    CartItemsEvent event,
    Emitter<PantryState> emit,
  ) async {
    final currentState = state;

    if (currentState is PantryLoaded) {
      final index = event.index;

      emit(currentState.copyWith(loadingIndex: index, isToCart: true));

      final res = await _cartItems(CartItemsParams(pantry: event.pantry));

      res.fold(
        (failure) {
          AppToast.show(failure.message, ToastType.error);
          emit(
            currentState.copyWith(
              loadingIndex: null,
              errorMessage: failure.message,
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
          _groceryBloc
            ..add(
              RequestedGroceryEvent(
                kitchenId: _userCubit.state.activeKitchenId,
              ),
            )
            ..add(
              GetAiGeneratedItemsEvent(
                kitchenId: _userCubit.state.activeKitchenId,
              ),
            );
        },
      );
    }
  }

  Future<void> _onDeleteItem(
    DeleteItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());

    final res = await _deleteItem(DeleteItemParams(pantry: event.pantry));

    res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        emit(PantrySuccess(successMessage));
        add(GetPantryItemsEvent(kitchenId: _userCubit.state.activeKitchenId));
        _homeBloc.add(
          GetPantriesItemsEventForHome(
            kitchenId: _userCubit.state.activeKitchenId,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateItem(
    UpdateItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    emit(PantryLoading());
    final res = await _updateItem(UpdateItemParams(pantry: event.pantry));

    res.fold(
      (failure) {
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        emit(PantrySuccess(successMessage));
        add(GetPantryItemsEvent(kitchenId: _userCubit.state.activeKitchenId));
        _homeBloc.add(
          GetPantriesItemsEventForHome(
            kitchenId: _userCubit.state.activeKitchenId,
          ),
        );
      },
    );
  }
}
