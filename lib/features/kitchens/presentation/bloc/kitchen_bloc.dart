import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final GetKitchens _getKitchens;
  final CreateKitchenUseCase _createKitchen;
  final JoinKitchenUseCase _joinKitchen;
  KitchenBloc({
    required GetKitchens getKitchens,
    required CreateKitchenUseCase createKitchen,
    required JoinKitchenUseCase joinKitchen,
  }) : _getKitchens = getKitchens,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       super(KitchenInitial()) {
    on<KitchenEvent>((_, emit) => emit(KitchensLoading()));
    on<FetchKitchens>(_onFetchKitchens);
    on<CreateKitchenEvent>(_onCreateKitchenEvent);
    on<JoinKitchenEvent>(_onJoinKitchenEvent);
  }

  Future<void> _onFetchKitchens(
    FetchKitchens event,
    Emitter<KitchenState> emit,
  ) async {
    emit(KitchensLoading());

    final res = await _getKitchens(NoParams());
    res.fold((failure) => emit(KitchenFailure(failure.message)), (kitchens) {
      emit(KitchensLoaded(kitchens));
    });
  }

  Future<void> _onCreateKitchenEvent(
    CreateKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final res = await _createKitchen(
      CreateKitchenParams(kitchenName: event.kitchenName),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onJoinKitchenEvent(
    JoinKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final res = await _joinKitchen(
      JoinKitchenUsecaseParams(invitationCode: event.invitationCode),
    );

    res.fold(
      (failure) => emit(KitchenFailure(failure.message)),
      (message) => emit(KitchenSuccess(message)),
    );
  }
}
