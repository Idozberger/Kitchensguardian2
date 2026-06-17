// ignore_for_file: library_prefixes
// home_event is imported with a prefix to avoid clashing with pantry_event types.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/services/notifications/pantry_stock_notifications.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart'
    as homeEvent;
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt_item.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
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
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_item_alert_partition.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';

part 'pantry_bloc_handlers.dart';
part 'pantry_bloc_handlers_part2.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final HomeBloc _homeBloc;
  final UserCubit _userCubit;
  final GroceryBloc _groceryBloc;
  final PlannerBloc _plannerBloc;
  final AddPantryItem _addPantryItem;

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
    required PlannerBloc plannerBloc,
    required ScanReceiptUseCase scanReceipt,
    required RequestItems requestItems,
    required ShowNotification showNotification,
    required CreatePantryUsecase createPantryUsecase,
    required CartItems cartItems,
    required DeletePantry deletePantry,
    required DeleteItem deleteItem,
    required UpdateItem updateItem,
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
       _plannerBloc = plannerBloc,
       _deleteItem = deleteItem,
       _updateItem = updateItem,

       super(PantryInitial()) {
    on<PantryAddItemEvent>((e, em) => _onAddPantryItem(this, e, em));
    on<GetPantryItemsEvent>((e, em) => _onGetPantryItems(this, e, em));

    on<ScanReceiptEvent>((e, em) => _onScanReceipt(this, e, em));
    on<PantryRequestItemEvent>((e, em) => _onRequestItems(this, e, em));
    on<IncrementItemEvent>((e, em) => _onIncrementItem(this, e, em));
    on<DecrementItemEvent>((e, em) => _onDecrementItem(this, e, em));
    on<ShowNotificationEvent>((e, em) => _onShowNotificationEvent(this, e, em));
    on<CreatePantryEvent>((e, em) => _onCreatePantry(this, e, em));
    on<GetUserStorageAreaForPantryViewEvent>(
      (e, em) => _onGetUserStorageAreaForPantryView(this, e, em),
    );
    on<DeletePantryEvent>((e, em) => _onDeletePantry(this, e, em));
    on<CartItemsEvent>((e, em) => _onCartItem(this, e, em));
    on<DeleteItemEvent>((e, em) => _onDeleteItem(this, e, em));
    on<UpdateItemEvent>((e, em) => _onUpdateItem(this, e, em));
    on<PantryAddScannedItemEvent>(
      (e, em) => _addScanItemsToPantry(this, e, em),
    );
  }
}
