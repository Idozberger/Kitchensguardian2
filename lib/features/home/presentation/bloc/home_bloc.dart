import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CreateKitchen _createKitchen;
  final JoinKitchen _joinKitchen;

  HomeBloc({
    required CreateKitchen createKitchen,
    required JoinKitchen joinKitchen,
  }) : _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       super(const HomeState()) {
    on<CreateKitchenEvent>(_onCreateKitchenEvent);
    on<JoinKitchenEvent>(_onJoinKitchenEvent);
  }

  Future<void> _onCreateKitchenEvent(
    CreateKitchenEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _createKitchen(
      CreateKitchenParams(kitchenName: event.kitchenName),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (message) =>
          emit(state.copyWith(isLoading: false, successMessage: message)),
    );
  }

  Future<void> _onJoinKitchenEvent(
    JoinKitchenEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final res = await _joinKitchen(
      JoinKitchenUsecaseParams(invitationCode: event.invitationCode),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (message) =>
          emit(state.copyWith(isLoading: false, successMessage: message)),
    );
  }
}
