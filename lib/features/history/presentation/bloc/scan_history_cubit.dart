import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';
import 'package:foodkitchen/features/history/domain/usecases/get_scan_history_usecase.dart';
import 'scan_history_state.dart';

class ScanHistoryCubit extends Cubit<ScanHistoryState> {
  final GetScanHistoryUsecase _getScanHistoryUsecase;
  ScanHistoryCubit({required GetScanHistoryUsecase getScanHistoryUseCase})
    : _getScanHistoryUsecase = getScanHistoryUseCase,
      super(ScanHistoryState(isLoading: false));

  Future<List<ScanHistoryEntity>> fetchHistory({
    required String pageNumber,
  }) async {
    emit(state.copyWith(isLoading: true));
    final res = await _getScanHistoryUsecase(
      GetScanHistoryUsecaseParams(pageNumber: pageNumber),
    );

    res.fold(
      (failure) =>
          emit(state.copyWith(error: failure.userMessage, isLoading: false)),
      (newItems) {
        final updatedItems = List<ScanHistoryEntity>.from(state.items)
          ..addAll(newItems);

        emit(
          state.copyWith(
            items: updatedItems,
            isLoading: false,
            hasMore: newItems.isNotEmpty,
          ),
        );
      },
    );

    return state.items;
  }

  void clearState() {
    emit(state.copyWith(items: [], hasMore: true));
  }
}
