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
            text: _isParseableExpiryDate(e.expireDate)
                ? e.expireDate
                : formatDate(DateTime.now()),
          ),
          manuFacturingDate: TextEditingController(),
          unit: e.unit,
          thumbnailBase64: e.thumbnail,
        )..needsReview = e.needsReview,
      )
      .toList();
}

bool _isParseableExpiryDate(String value) {
  try {
    parseDate(value);
    return true;
  } catch (_) {
    return false;
  }
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
  final parsedQty = double.tryParse(qty);
  if (parsedQty == null || parsedQty <= 0) {
    return "$displayName: quantity must be a valid number greater than 0.";
  }
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
    } else if (item.thumbnailBase64 != null &&
        item.thumbnailBase64!.isNotEmpty) {
      // Reuse the original scan payload as-is - avoids a pointless
      // decode-then-re-encode round trip for items the user never touched.
      return "data:image/jpeg;base64,${item.thumbnailBase64}";
    } else if (item.fileBytes != null && item.fileBytes!.isNotEmpty) {
      return "data:image/jpeg;base64,${base64Encode(item.fileBytes!)}";
    }
  } catch (e) {
    devPrint("Image compression failed: $e");
  }
  return null;
}

/// Lazily-built receipt items list (image preview + one row per scanned
/// item). Extracted from [_CaptureDetailsPageState] so the `ListView.builder`
/// shape — required for high-volume receipts — is directly testable without
/// standing up the page's bloc/DI dependencies.
class ReceiptItemsListView extends StatelessWidget {
  const ReceiptItemsListView({
    super.key,
    required this.imagePath,
    required this.items,
    required this.userCubit,
    required this.onItemRemoved,
    required this.onFieldChanged,
  });

  final String imagePath;
  final List<PantryItem> items;
  final UserCubit userCubit;
  final ValueChanged<PantryItem> onItemRemoved;
  final VoidCallback onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: gapAll(20),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              ImagePreviewWidget(imagePath: imagePath),
              SizedBox(height: h(12)),
            ],
          );
        }

        final itemIndex = index - 1;
        final item = items[itemIndex];
        return Column(
          children: [
            if (itemIndex > 0)
              Padding(
                padding: gapOnly(bottom: 16),
                child: const Divider(color: Color(0xFFF4F4F4), height: 1),
              ),
            ReceiptPantryItemFormTile(
              item: item,
              isFirstItem: itemIndex == 0,
              userCubit: userCubit,
              onItemRemoved: () => onItemRemoved(item),
              onFieldChanged: onFieldChanged,
            ),
          ],
        );
      },
    );
  }
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
        sharedIngredientId: item.sharedIngredientId,
      ),
    );
  }

  return Pantry(kitchenId: kitchenId, items: pantryItems);
}
