import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';

class ScanHistoryState {
  final bool isLoading;
  final bool hasMore;
  final List<ScanHistoryEntity> items;
  final String? error;

  const ScanHistoryState({
    this.isLoading = false,
    this.hasMore = true,
    this.items = const [],
    this.error,
  });

  ScanHistoryState copyWith({
    bool? isLoading,
    bool? hasMore,
    List<ScanHistoryEntity>? items,
    String? error,
  }) {
    return ScanHistoryState(
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      items: items ?? this.items,
      error: error,
    );
  }
}
