import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/dashboard_join_request_firestore_datasource.dart';

class DashboardJoinRequestFirestoreDatasourceImpl
    implements DashboardJoinRequestFirestoreDatasource {
  DashboardJoinRequestFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<Map<String, dynamic>?> fetchUserDocument(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  @override
  Future<Map<String, dynamic>?> fetchKitchenOwnedByHost({
    required String hostUserId,
    required String kitchenId,
  }) async {
    final query = await _db
        .collection('kitchens')
        .where('user_id', isEqualTo: hostUserId)
        .where('kitchen_id', isEqualTo: kitchenId)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  @override
  Future<void> addNotificationDocument(Map<String, dynamic> data) {
    return _db.collection('notifications').add(data);
  }

  @override
  Future<void> patchJoinRequestNotification({
    required String kitchenId,
    required String senderUserId,
    required Map<String, dynamic> updates,
  }) async {
    final query = await _db
        .collection('notifications')
        .where('kitchen_id', isEqualTo: kitchenId)
        .where('sender_user_id', isEqualTo: senderUserId)
        .get();
    if (query.docs.isEmpty) return;
    await query.docs.first.reference.update(updates);
  }

  @override
  Future<void> markNotificationsReadByLegacyIntId(int id) async {
    final query = await _db
        .collection('notifications')
        .where('id', isEqualTo: id)
        .get();
    for (final doc in query.docs) {
      await doc.reference.update({'status': true});
    }
  }
}
