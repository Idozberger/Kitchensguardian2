import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/add_custom_item.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/add_mylist_to_inventory.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/delete_kitchen_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/get_ai_generated_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/get_requested_items.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/update_bucket_type.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';

class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final GetRequestedItems _getRequestedItems;
  final UpdateBucketType _updateBucketType;
  final AddMylistToInventory _addMylistToInventory;
  final GetAiGeneratedItems _getAiGeneratedItems;
  final DeleteKitchenItems _deleteKitchenItems;
  final AddCustomItem _addCustomItem;

  GroceryBloc({
    required GetRequestedItems getRequestedItems,
    required UpdateBucketType updateBucketType,
    required AddMylistToInventory addMylistToInventory,
    required GetAiGeneratedItems getAiGeneratedItems,
    required DeleteKitchenItems deleteKitchenItems,
    required AddCustomItem addCustomItem,
  }) : _getRequestedItems = getRequestedItems,
       _updateBucketType = updateBucketType,
       _addMylistToInventory = addMylistToInventory,
       _getAiGeneratedItems = getAiGeneratedItems,
       _deleteKitchenItems = deleteKitchenItems,
       _addCustomItem = addCustomItem,
       super(GroceryState()) {
    on<GroceryEvent>((_, emit) => emit(state.copyWith(isLoading: true)));
    on<RequestedGroceryEvent>(_onGetRequestedItems);
    on<UpdateBucketTypeEvent>(_onUpdateBucketType);
    on<AddMylistToInventoryEvent>(_onAddMyListToInventory);
    on<GetAiGeneratedItemsEvent>(_onGetAiGeneratedItems);
    on<DeleteKitchenItemsEvent>(_onDeleteKitchenItems);
    on<AddCustomItemEvent>(_onAddCustomItem);
  }

  Future<void> _onGetRequestedItems(
    RequestedGroceryEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _getRequestedItems(
      GetRequestedItemsParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (requestedItemsList) {
        final requestedItems = requestedItemsList
            .where((item) => item.bucketType == "requested")
            .toList();

        final finalListItems = requestedItemsList
            .where((item) => item.bucketType == "mylist")
            .toList();

        emit(
          state.copyWith(
            requestedItemsList: requestedItems,
            finalListItemsList: finalListItems,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateBucketType(
    UpdateBucketTypeEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _updateBucketType(
      UpdateBucketTypeParams(
        bucketType: event.bucketType,
        itemIds: event.itemIds,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (updatedItemsList) {
        final requestedItems = updatedItemsList
            .where((item) => item.bucketType == "requested")
            .toList();

        final finalListItems = updatedItemsList
            .where((item) => item.bucketType == "mylist")
            .toList();

        emit(
          state.copyWith(
            successMessage: "Items moved to mylist",
            requestedItemsList: requestedItems,
            finalListItemsList: finalListItems,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onAddMyListToInventory(
    AddMylistToInventoryEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _addMylistToInventory(
      AddMylistToInventoryParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (updatedItemsList) {
        final requestedItems = updatedItemsList
            .where((item) => item.bucketType == "requested")
            .toList();

        final finalListItems = updatedItemsList
            .where((item) => item.bucketType == "mylist")
            .toList();

        emit(
          state.copyWith(
            successMessage: "Items successfully added to kitchen inventory",
            requestedItemsList: requestedItems,
            finalListItemsList: finalListItems,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onGetAiGeneratedItems(
    GetAiGeneratedItemsEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _getAiGeneratedItems(
      GetAiGeneratedItemsParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (aiGeneratedItems) {
        emit(
          state.copyWith(aiGeneratedList: aiGeneratedItems, isLoading: false),
        );
      },
    );
  }

  Future<void> _onDeleteKitchenItems(
    DeleteKitchenItemsEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _deleteKitchenItems(
      DeleteKitchenItemsParams(
        itemIds: event.itemIds,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (updatedItemsList) {
        final requestedItems = updatedItemsList
            .where((item) => item.bucketType == "requested")
            .toList();

        final finalListItems = updatedItemsList
            .where((item) => item.bucketType == "mylist")
            .toList();

        emit(
          state.copyWith(
            successMessage: "Items deleted successfully",
            requestedItemsList: requestedItems,
            finalListItemsList: finalListItems,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> _onAddCustomItem(
    AddCustomItemEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _addCustomItem(
      AddCustomItemParams(
        name: event.name,
        quantity: event.quantity,
        unit: event.unit,
        bucketType: event.bucketype,
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message, isLoading: false)),
      (requestedItemsList) {
        final requestedItems = requestedItemsList
            .where((item) => item.bucketType == "requested")
            .toList();

        final finalListItems = requestedItemsList
            .where((item) => item.bucketType == "mylist")
            .toList();

        emit(
          state.copyWith(
            requestedItemsList: requestedItems,
            finalListItemsList: finalListItems,
            isLoading: false,
            successMessage: "Item added to final list successfully",
          ),
        );
      },
    );
  }
}
