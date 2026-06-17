import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/dashboard_notifications_firestore_datasource.dart';

class DashboardNotificationsFirestoreDatasourceImpl
    implements DashboardNotificationsFirestoreDatasource {
  DashboardNotificationsFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<Map<String, dynamic>>> watchNotificationsForHost(
    String hostUserId,
  ) {
    return _db
        .collection('notifications')
        .where('host_user_id', isEqualTo: hostUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final m = Map<String, dynamic>.from(d.data());
            m['_firestoreDocId'] = d.id;
            return m;
          }).toList(),
        );
  }
}
