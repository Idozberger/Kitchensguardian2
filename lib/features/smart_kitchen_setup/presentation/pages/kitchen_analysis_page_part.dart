part of 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/kitchen_analysis_page.dart';

PantryItem kitchenAnalysisMapScannedToPantryItem(ScannedItemEntity item) {
  return PantryItem(
      nameController: TextEditingController(text: item.name),
      qtyController: TextEditingController(
        text: formatQuantity(item.quantity, grouped: false),
      ),
      expireDate: TextEditingController(text: item.expiryDate),
      manuFacturingDate: TextEditingController(),
      estimatedWeightGrams: item.estimatedWeightGrams,
    )
    ..unit = item.unit
    ..pantry = item.recommendedStorage.isNotEmpty
        ? item.recommendedStorage
        : item.area
    ..needsReview = item.needsReview
    ..sharedIngredientId = item.sharedIngredientId
    ..libraryMatch = item.libraryMatch;
}

Map<String, dynamic> kitchenAnalysisToEditPayload(PantryItem item) {
  final map = <String, dynamic>{
    'name': item.nameController.text.trim(),
    'quantity': double.tryParse(item.qtyController.text.trim()) ?? 0,
    'unit': item.unit ?? '',
    'recommended_storage': (item.pantry ?? '').toLowerCase(),
    'expiry_date': formatExpiry(item.expireDate.text),
  };

  final sharedId = item.sharedIngredientId;
  if (sharedId != null && sharedId.isNotEmpty) {
    final parsedId = int.tryParse(sharedId);
    if (parsedId != null) {
      map['shared_ingredient_id'] = parsedId;
    }
  }

  return map;
}

String? kitchenAnalysisValidateRow(PantryItem item) {
  final name = item.nameController.text.trim();
  final qty = item.qtyController.text.trim();

  if (name.isEmpty) {
    return "Please enter the item name.";
  }

  if (name.length < 3) {
    return "Item name must be at least 3 characters long.";
  }

  if (qty.isEmpty) {
    return "Please enter the quantity.";
  }

  return null;
}
