import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/get_kitchens.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/join_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/leave_kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/usecases/remove_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final GetKitchens _getKitchens;
  final CreateKitchenUseCase _createKitchen;
  final JoinKitchenUseCase _joinKitchen;
  final LeaveKitchenUsecase _leaveKitchenUsecase;
  final RemoveKitchenUsecase _removeKitchenUsecase;
  final HomeBloc _homeBloc;
  final PlannerBloc _plannerBloc;
  final GroceryBloc _groceryBloc;

  KitchenBloc({
    required GetKitchens getKitchens,
    required CreateKitchenUseCase createKitchen,
    required JoinKitchenUseCase joinKitchen,
    required HomeBloc homeBloc,
    required PlannerBloc plannerBloc,
    required GroceryBloc groceryBloc,
    required LeaveKitchenUsecase leaveKitchenUsecase,
    required RemoveKitchenUsecase removeKitchenUsecase,
  }) : _getKitchens = getKitchens,
       _createKitchen = createKitchen,
       _joinKitchen = joinKitchen,
       _leaveKitchenUsecase = leaveKitchenUsecase,
       _removeKitchenUsecase = removeKitchenUsecase,
       _homeBloc = homeBloc,
       _plannerBloc = plannerBloc,
       _groceryBloc = groceryBloc,
       super(KitchenInitial()) {
    on<KitchenEvent>((_, emit) => emit(KitchensLoading()));
    on<FetchKitchens>(_onFetchKitchens);
    on<CreateKitchenEvent>(_onCreateKitchenEvent);
    on<JoinKitchenEvent>(_onJoinKitchenEvent);
    on<SwitchKitchenEvent>(_onSwitchKitchen);
    on<LeaveKitchenEvent>(_onLeaveKitchen);
    on<RemoveKitchenEvent>(_onRemoveKitchen);
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
    add(FetchKitchens());
  }

  Future<void> _onLeaveKitchen(
    LeaveKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final res = await _leaveKitchenUsecase(
      LeaveKitchenParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onRemoveKitchen(
    RemoveKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    final res = await _removeKitchenUsecase(
      RemoveKitchenParams(kitchenId: event.kitchenId),
    );

    res.fold((failure) => emit(KitchenFailure(failure.message)), (message) {
      emit(KitchenSuccess(message));
    });
  }

  Future<void> _onSwitchKitchen(
    SwitchKitchenEvent event,
    Emitter<KitchenState> emit,
  ) async {
    _homeBloc.add(GetPantriesItemsEventForHome(kitchenId: event.kitchenId));
    _groceryBloc.add(RequestedGroceryEvent(kitchenId: event.kitchenId));
    _plannerBloc.add(GetAllWeeklyPlansEvent());
  }
}
