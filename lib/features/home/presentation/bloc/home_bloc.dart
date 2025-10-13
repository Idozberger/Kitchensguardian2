import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserCubit _userCubit;
  final CreateKitchen _createKitchen;
  final JoinKitchen _joinKitchen;

  HomeBloc({
    required UserCubit userCubit,
    required CreateKitchen createKitchen,
    required JoinKitchen joinKitchen,
  }) : _userCubit = userCubit,
       _createKitchen = createKitchen,
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
      (kitchen) {
        _userCubit.updateActiveKitchenId(activeKitchenId: kitchen.kitchenId);
        emit(state.copyWith(isLoading: false, successMessage: kitchen.message));
      },
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
