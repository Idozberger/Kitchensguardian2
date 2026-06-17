import 'package:foodkitchen/features/dashboard/domain/entities/user_kitchen_preview.dart';

abstract class UserKitchenPreviewFirestoreDatasource {
  Future<UserKitchenPreview?> fetchPreview({
    required String userId,
    required String kitchenId,
  });
}
