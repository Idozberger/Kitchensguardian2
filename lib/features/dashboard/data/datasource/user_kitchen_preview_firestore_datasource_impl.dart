import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/user_kitchen_preview_firestore_datasource.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/user_kitchen_preview.dart';

class UserKitchenPreviewFirestoreDatasourceImpl
    implements UserKitchenPreviewFirestoreDatasource {
  UserKitchenPreviewFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<UserKitchenPreview?> fetchPreview({
    required String userId,
    required String kitchenId,
  }) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    final userData = userDoc.data();
    if (userData == null) return null;

    final userName =
        '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
    final userEmail = userData['email']?.toString() ?? '';

    final kitchenDoc = await _db.collection('kitchens').doc(kitchenId).get();
    final kitchenData = kitchenDoc.data();
    final kitchenName = kitchenData?['kitchen_name']?.toString() ?? '';

    return UserKitchenPreview(
      userName: userName,
      userEmail: userEmail,
      kitchenName: kitchenName,
    );
  }
}
