import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';

sealed class PantryState {
  const PantryState();
}

final class PantryInitial extends PantryState {}

final class PantryLoading extends PantryState {}

final class SubmittingItemLoading extends PantryState {}

final class PantryScanItemsLoading extends PantryState {}

class PantryLoaded extends PantryState {
  final List<PantryItemEntity> pantryItems;
  final List<PantryItemEntity> lowStockItems;
  final List<PantryItemEntity> expiringItems;

  final String? errorMessage;
  final String? successMessage;
  final bool isToCart;
  final int? loadingIndex;

  PantryLoaded({
    required this.pantryItems,
    required this.lowStockItems,
    required this.expiringItems,
    this.errorMessage,
    this.successMessage,
    this.isToCart = false,
    this.loadingIndex,
  });

  PantryLoaded copyWith({
    List<PantryItemEntity>? pantryItems,
    List<PantryItemEntity>? lowStockItems,
    List<PantryItemEntity>? expiringItems,
    String? errorMessage,
    String? successMessage,
    bool? isToCart,
    int? loadingIndex,
  }) {
    return PantryLoaded(
      pantryItems: pantryItems ?? this.pantryItems,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      expiringItems: expiringItems ?? this.expiringItems,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isToCart: isToCart ?? this.isToCart,
      loadingIndex: loadingIndex,
    );
  }
}

class PantrySuccess extends PantryState {
  final String successMessage;
  PantrySuccess(this.successMessage);
}

class PantryFailure extends PantryState {
  final String errorMessage;
  PantryFailure(this.errorMessage);
}

class ScanReceiptLoaded extends PantryState {
  final ScanReceiptEntity scanReceipt;
  ScanReceiptLoaded(this.scanReceipt);
  ScanReceiptLoaded copyWith({ScanReceiptEntity? scanReceipt}) {
    return ScanReceiptLoaded(scanReceipt ?? this.scanReceipt);
  }
}

class UserStorageAreaLoaded extends PantryState {
  final List<PantriesCommonEntity> userStorageAreas;
  UserStorageAreaLoaded(this.userStorageAreas);
}
