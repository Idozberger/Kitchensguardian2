import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';

class KitchenSetupScanResult {
  final String sessionId;
  final List<ScannedItemEntity> items;

  const KitchenSetupScanResult({required this.sessionId, required this.items});
}
