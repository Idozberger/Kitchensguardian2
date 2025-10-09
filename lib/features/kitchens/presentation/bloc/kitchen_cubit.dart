import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

class KitchenCubit extends Cubit<KitchenState> {
  final GetKitchens _getKitchens;

  KitchenCubit({required GetKitchens getKitchens})
    : _getKitchens = getKitchens,
      super(KitchenState());

  Future<void> getKitchens() async {
    emit(state.copyWith(loadingKitchens: true));

    final result = await _getKitchens(NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingJoinedKitchens: false,
            errorMessage: failure.message,
          ),
        );
      },
      (kitchens) {
        emit(
          state.copyWith(loadingJoinedKitchens: false, kitchenList: kitchens),
        );
        print("Cubit" + state.kitchenList.toString());
      },
    );
  }
}
