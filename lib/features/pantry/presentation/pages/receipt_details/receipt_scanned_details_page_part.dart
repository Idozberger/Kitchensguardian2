// ignore_for_file: unnecessary_underscores

part of 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_scanned_details_page.dart';

List<PantryItem> receiptMapScanToPantryItems(ScanReceiptEntity scanReceipt) {
  return scanReceipt.items
      .map(
        (e) => PantryItem(
          pantry: e.group,
          nameController: TextEditingController(text: e.name),
          qtyController: TextEditingController(text: e.amount),
          expireDate: TextEditingController(
            text: e.expireDate == "null"
                ? formatDate(DateTime.now())
                : e.expireDate,
          ),
          manuFacturingDate: TextEditingController(),
          unit: e.unit,
          fileBytes: e.thumbnail,
        )..needsReview = e.needsReview,
      )
      .toList();
}

String? receiptValidatePantryItem(PantryItem item, int index) {
  final name = item.nameController.text.trim();
  final qty = item.qtyController.text.trim();
  final unit = item.unit?.trim();
  final pantry = item.pantry?.trim();
  final expiry = item.expireDate.text.trim();
  final displayName = name.isEmpty ? "Item ${index + 1}" : name;

  if (name.isEmpty) return "$displayName: please enter the item name.";
  if (name.length < 3) {
    return "$displayName: item name must be at least 3 characters long.";
  }
  if (qty.isEmpty) return "$displayName: please enter the quantity.";
  if (unit == null || unit.isEmpty) {
    return "$displayName: please select a unit.";
  }
  if (pantry == null || pantry.isEmpty) {
    return "$displayName: please select a pantry.";
  }
  if (expiry.isEmpty) {
    return "$displayName: please enter the expiring date.";
  }
  return null;
}

Future<String> receiptCompressImageFile(File imageFile) async {
  final result = await FlutterImageCompress.compressWithList(
    imageFile.readAsBytesSync(),
    minWidth: 800,
    minHeight: 600,
    quality: 15,
    rotate: 0,
    inSampleSize: 1,
    autoCorrectionAngle: true,
    format: CompressFormat.jpeg,
    keepExif: false,
  );
  return "data:image/jpeg;base64,${base64Encode(result)}";
}

Future<String?> receiptPantryItemThumbnailBase64(PantryItem item) async {
  try {
    if (item.file != null) {
      return await receiptCompressImageFile(item.file!);
    } else if (item.fileBytes != null && item.fileBytes!.isNotEmpty) {
      return "data:image/jpeg;base64,${base64Encode(item.fileBytes!)}";
    }
  } catch (e) {
    devPrint("Image compression failed: $e");
  }
  return null;
}

Future<Pantry> receiptBuildPantryFromItems({
  required List<PantryItem> items,
  required String kitchenId,
}) async {
  final pantryItems = <PantryItemEntity>[];

  for (final item in items) {
    final thumbnailBase64 = await receiptPantryItemThumbnailBase64(item);

    pantryItems.add(
      PantryItemEntity(
        name: item.nameController.text.trim(),
        quantity: double.tryParse(item.qtyController.text.trim()) ?? 0.0,
        unit: item.unit ?? "",
        group: item.pantry ?? 'Fridge',
        expireDate: item.expireDate.text.trim(),
        thumbnail: thumbnailBase64 ?? "",
        expiryStatus: '',
        stockStatus: '',
        itemId: '',
      ),
    );
  }

  return Pantry(kitchenId: kitchenId, items: pantryItems);
}
