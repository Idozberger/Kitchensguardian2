import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_join_status_firestore_datasource.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/join_request_info.dart';

class KitchenJoinStatusFirestoreDatasourceImpl
    implements KitchenJoinStatusFirestoreDatasource {
  KitchenJoinStatusFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<List<JoinRequestInfo>> watchPendingJoinRequestsForSender(
    String userId,
  ) {
    return _db
        .collection('notifications')
        .where('sender_user_id', isEqualTo: userId)
        .where('approved_by', isNotEqualTo: userId)
        .where('kitchen_joining_status', isEqualTo: 'Pending')
        .orderBy('approved_by')
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return <JoinRequestInfo>[];

          final results = <JoinRequestInfo>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final kitchenId = data['kitchen_id'] as String? ?? '';
            String kitchenName = data['kitchen_name'] as String? ?? '';

            if (kitchenName.isEmpty && kitchenId.isNotEmpty) {
              final kitchenDoc = await _db
                  .collection('kitchens')
                  .doc(kitchenId)
                  .get();
              kitchenName =
                  kitchenDoc.data()?['kitchen_name'] as String? ??
                  'Unknown Kitchen';
            }

            final status =
                data['kitchen_joining_status'] as String? ?? 'Pending';
            devLog(
              'Kitchen join request doc=${doc.id} kitchenId=$kitchenId status=$status',
              name: 'KitchenJoin',
            );
            results.add(
              JoinRequestInfo(
                status: status,
                kitchenName: kitchenName,
                kitchenId: kitchenId,
                date: data['date'] as String? ?? '',
              ),
            );
          }
          return results;
        });
  }
}
