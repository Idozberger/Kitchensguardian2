import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';

class GroceryState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final List<RequestedItemEntity>? requestedItemsList;
  final List<RequestedItemEntity>? finalListItemsList;
  final List<RequestedItemEntity>? aiGeneratedList;

  const GroceryState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
    this.requestedItemsList,
    this.finalListItemsList,
    this.aiGeneratedList,
  });

  GroceryState copyWith({
    bool? isLoading,
    String? successMessage,
    String? errorMessage,
    List<RequestedItemEntity>? requestedItemsList,
    List<RequestedItemEntity>? finalListItemsList,
    List<RequestedItemEntity>? aiGeneratedList,
  }) {
    return GroceryState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage,
      errorMessage: errorMessage,
      requestedItemsList: requestedItemsList ?? this.requestedItemsList,
      finalListItemsList: finalListItemsList ?? this.finalListItemsList,
      aiGeneratedList: aiGeneratedList ?? this.aiGeneratedList,
    );
  }
}
