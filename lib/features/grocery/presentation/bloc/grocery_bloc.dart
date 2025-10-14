import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/grocery/domain/usecases/get_requested_items.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';

class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final GetRequestedItems _getRequestedItems;
  GroceryBloc({required GetRequestedItems getRequestedItems})
    : _getRequestedItems = getRequestedItems,

      super(GroceryInitial()) {
    on<GroceryEvent>((_, emit) => emit(GroceryLoading()));
    on<RequestedGroceryEvent>(_onGetRequestedItems);
  }

  Future<void> _onGetRequestedItems(
    RequestedGroceryEvent event,
    Emitter<GroceryState> emit,
  ) async {
    final res = await _getRequestedItems(
      GetRequestedItemsParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(GroceryFailure(failure.message)), (
      requestedItemsList,
    ) {
      emit(RequestedGroceryLoaded(requestedItemsList));
    });
  }
}
