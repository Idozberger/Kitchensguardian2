import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/features/home/domain/usecases/create_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_all_weekly_plans_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/get_pantries_usecase.dart';
import 'package:foodkitchen/features/home/domain/usecases/join_kitchen_usecase.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserCubit _userCubit;
  final CreateKitchen _createKitchen;
  final JoinKitchen _joinKitchen;
  final GetPantriesForHome _getPantriesForHome;
  final GetAllWeeklyPlansForHome _getAllWeeklyPlansForHome;
  HomeBloc({
    required UserCubit userCubit,
    required CreateKitchen createKitchen,
    required JoinKitchen joinKitchen,
    required GetPantriesForHome getPantriesForHome,
    required GetAllWeeklyPlansForHome getAllWeeklyPlansForHome,
  }) : _userCubit = userCubit,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _getAllWeeklyPlansForHome = getAllWeeklyPlansForHome,
       _getPantriesForHome = getPantriesForHome,
       super(const HomeState()) {
    on<CreateKitchenEventForHome>(_onCreateKitchenEvent);
    on<GetPantriesItemsEventForHome>(_onGetPantryItems);
    on<JoinKitchenEventForHome>(_onJoinKitchenEvent);
    on<GetAllWeeklyPlansEventForHome>(_onGetAllWeeklyPlans);
  }

  Future<void> _onCreateKitchenEvent(
    CreateKitchenEventForHome event,
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
        _userCubit.updateActiveKitchenIdInvitationCodeAndRole(
          activeKitchenId: kitchen.kitchenId,
          invitationCode: kitchen.invitationCard,
          role: "host",
        );

        emit(state.copyWith(isLoading: false, successMessage: kitchen.message));
      },
    );
  }

  Future<void> _onJoinKitchenEvent(
    JoinKitchenEventForHome event,
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

  Future<void> _onGetPantryItems(
    GetPantriesItemsEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final res = await _getPantriesForHome(
      GetPantriesForHomeParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (pantries) =>
          emit(state.copyWith(isLoading: false, pantryItems: pantries)),
    );
  }

  Future<void> _onGetAllWeeklyPlans(
    GetAllWeeklyPlansEventForHome event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(loadingWeeklyPlans: true));
    final res = await _getAllWeeklyPlansForHome(NoParams());

    res.fold(
      (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            loadingWeeklyPlans: false,
          ),
        );
      },
      (getAllWeeklyPlans) {
        emit(
          state.copyWith(
            dateBasedPlan: getAllWeeklyPlans,
            loadingWeeklyPlans: false,
          ),
        );
      },
    );
  }
}
