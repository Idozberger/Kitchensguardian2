part of 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/kitchen_analysis_page.dart';

PantryItem kitchenAnalysisMapScannedToPantryItem(ScannedItemEntity item) {
  return PantryItem(
      nameController: TextEditingController(text: item.name),
      qtyController: TextEditingController(text: item.quantity.toString()),
      expireDate: TextEditingController(text: item.expiryDate),
      manuFacturingDate: TextEditingController(),
      estimatedWeightGrams: item.estimatedWeightGrams,
    )
    ..unit = item.unit
    ..pantry = item.area;
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

Future<String> kitchenAnalysisCompressImage(File? imageFile) async {
  if (imageFile == null) return "";
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
