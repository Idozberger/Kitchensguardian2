import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_document_firestore_datasource.dart';

class KitchenDocumentFirestoreDatasourceImpl
    implements KitchenDocumentFirestoreDatasource {
  KitchenDocumentFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<void> mergeUpdateKitchenForHost({
    required String kitchenId,
    required String userId,
    required String kitchenName,
    required String role,
    required String invitationCode,
  }) {
    final ref = _db.collection('kitchens').doc(kitchenId);
    final data = <String, dynamic>{
      'kitchen_id': kitchenId,
      'user_id': userId,
      'kitchen_name': kitchenName,
      'role': role,
      'invitation_code': invitationCode,
      'updated_at': FieldValue.serverTimestamp(),
    };
    return ref.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> setKitchenDocumentForNewHost({
    required String kitchenId,
    required String userId,
    required String invitationCode,
    required String? kitchenName,
  }) {
    final ref = _db.collection('kitchens').doc(kitchenId);
    final data = <String, dynamic>{
      'kitchen_id': kitchenId,
      'user_id': userId,
      'kitchen_name': kitchenName,
      'role': 'host',
      'invitation_code': invitationCode,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
    return ref.set(data);
  }
}
