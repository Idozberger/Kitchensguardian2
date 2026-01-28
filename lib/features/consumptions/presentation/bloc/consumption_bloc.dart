import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/get_consumption_confirmation_count.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/get_consumption_confirmation_pending.dart';
import 'package:foodkitchen/features/consumptions/domain/usecases/respond_consumption_confirmation.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_state.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';

class ConsumptionBloc extends Bloc<ConsumptionEvent, ConsumptionState> {
  final GetConsumptionConfirmationPendingUsecase
  _getConsumptionConfirmationPending;
  final GetConsumptionConfirmationCountUseCase _getConsumptionConfirmationCount;
  final RespondConsumptionConfirmationUseCase _respondConsumptionConfirmation;
  final HomeBloc _homeBloc;

  ConsumptionBloc({
    required HomeBloc homeBloc,
    required GetConsumptionConfirmationPendingUsecase
    getConsumptionConfirmationPending,
    required GetConsumptionConfirmationCountUseCase
    getConsumptionConfirmationCount,
    required RespondConsumptionConfirmationUseCase
    respondConsumptionConfirmation,
  }) : _getConsumptionConfirmationPending = getConsumptionConfirmationPending,
       _getConsumptionConfirmationCount = getConsumptionConfirmationCount,
       _respondConsumptionConfirmation = respondConsumptionConfirmation,
       _homeBloc = homeBloc,
       super(const ConsumptionState()) {
    on<GetConsumptionConfirmationPendingEvent>(
      _onGetConsumptionConfirmationPending,
    );
    on<GetConsumptionConfirmationPendingCountEvent>(
      _onGetConsumptionConfirmationPendingCount,
    );
    on<RespondConsumptionConfirmationPendingEvent>(
      _onRespondConsumptionConfirmationPending,
    );
  }

  Future<void> _onRespondConsumptionConfirmationPending(
    RespondConsumptionConfirmationPendingEvent event,
    Emitter<ConsumptionState> emit,
  ) async {
    emit(
      state.copyWith(respondingOnConsumptionLoader: true, errorMessage: null),
    );

    final res = await _respondConsumptionConfirmation(
      RespondConsumptionConfirmationUseCaseParams(
        confirmationId: event.confirmationId,
        actualQuantityRemaining: event.actualQuantityRemaining,
        responseText: event.responseText,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(respondingOnConsumptionLoader: false));
        AppToast.show(failure.message, ToastType.error);
      },
      (successMessage) {
        emit(
          state.copyWith(
            respondingOnConsumptionLoader: false,
            successMessage: successMessage,
          ),
        );

        add(
          GetConsumptionConfirmationPendingCountEvent(
            kitchenId: event.kitchenId,
          ),
        );
        add(GetConsumptionConfirmationPendingEvent(kitchenId: event.kitchenId));
      },
    );
  }

  Future<void> _onGetConsumptionConfirmationPendingCount(
    GetConsumptionConfirmationPendingCountEvent event,
    Emitter<ConsumptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final res = await _getConsumptionConfirmationCount(
      GetConsumptionConfirmationCountUseCaseParams(kitchenId: event.kitchenId),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (count) {
        emit(
          state.copyWith(
            isLoading: false,
            comsumptionConfirmationPendingCount: count,
          ),
        );
      },
    );
  }

  Future<void> _onGetConsumptionConfirmationPending(
    GetConsumptionConfirmationPendingEvent event,
    Emitter<ConsumptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final res = await _getConsumptionConfirmationPending(
      GetConsumptionConfirmationPendingUsecaseParams(
        kitchenId: event.kitchenId,
      ),
    );

    res.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (pendingList) {
        emit(
          state.copyWith(
            isLoading: false,
            comsumptionConfirmationPending: pendingList,
          ),
        );
      },
    );
  }
}
