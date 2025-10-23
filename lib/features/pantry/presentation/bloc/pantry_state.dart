import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';

sealed class PantryState {
  const PantryState();
}

final class PantryInitial extends PantryState {}

final class PantryLoading extends PantryState {}

class PantryLoaded extends PantryState {
  final List<PantryItemEntity> pantryItems;
  PantryLoaded(this.pantryItems);
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
