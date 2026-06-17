import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/features/planner/domain/datasources/recipe_start_request_firestore_datasource.dart';

class RecipeStartRequestFirestoreDatasourceImpl
    implements RecipeStartRequestFirestoreDatasource {
  RecipeStartRequestFirestoreDatasourceImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<Map<String, dynamic>?> fetchKitchenByKitchenId(
    String kitchenId,
  ) async {
    final q = await _db
        .collection('kitchens')
        .where('kitchen_id', isEqualTo: kitchenId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.data();
  }

  @override
  Future<Map<String, dynamic>?> fetchUserDocument(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  @override
  Future<void> addRecipeStartRequest(Map<String, dynamic> data) {
    return _db.collection('recipe_start_requests').add(data);
  }

  @override
  Future<void> completePendingRequestForHost({
    required String hostUserId,
    required String recipeId,
  }) async {
    final q = await _db
        .collection('recipe_start_requests')
        .where('host_user_id', isEqualTo: hostUserId)
        .where('recipe_id', isEqualTo: recipeId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return;
    await q.docs.first.reference.update({
      'recipe_status': 'Completed',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchRecipeStartRequestsForKitchen(
    String kitchenId,
  ) {
    return _db
        .collection('recipe_start_requests')
        .where('kitchen_id', isEqualTo: kitchenId)
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
