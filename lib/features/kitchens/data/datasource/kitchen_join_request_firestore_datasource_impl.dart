import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_join_request_firestore_datasource.dart';

class KitchenJoinRequestFirestoreDatasourceImpl
    implements KitchenJoinRequestFirestoreDatasource {
  KitchenJoinRequestFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<Map<String, dynamic>?> fetchKitchenByInvitationCode(
    String invitationCode,
  ) async {
    final snap = await _db
        .collection('kitchens')
        .where('invitation_code', isEqualTo: invitationCode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  @override
  Future<Map<String, dynamic>?> fetchUserDocument(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  @override
  Future<bool> hasPendingKitchenJoinRequest({
    required String senderUserId,
    required String kitchenId,
  }) async {
    final pending = await _db
        .collection('notifications')
        .where('sender_user_id', isEqualTo: senderUserId)
        .where('kitchen_id', isEqualTo: kitchenId)
        .where('kitchen_joining_status', isEqualTo: 'Pending')
        .limit(1)
        .get();
    return pending.docs.isNotEmpty;
  }

  @override
  Future<void> addNotification(Map<String, dynamic> data) {
    return _db.collection('notifications').add(data);
  }
}
