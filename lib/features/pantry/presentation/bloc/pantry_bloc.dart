import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/pantry/domain/usecases/add_pantry_item.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final AddPantryItem _addPantryItem;
  PantryBloc({required AddPantryItem addPantryItem})
    : _addPantryItem = addPantryItem,

      super(PantryInitial()) {
    on<PantryEvent>((_, emit) => emit(PantryLoading()));
    on<PantryAddItemEvent>(_onAddPantryItem);
  }

  Future<void> _onAddPantryItem(
    PantryAddItemEvent event,
    Emitter<PantryState> emit,
  ) async {
    final res = await _addPantryItem(AddPantryItemParams(pantry: event.pantry));

    res.fold((failure) => emit(PantryFailure(failure.message)), (message) {
      emit(PantrySuccess(message));
    });
  }
}
