/// Firestore writes for `kitchens/{kitchenId}` documents (host context).
abstract class KitchenDocumentFirestoreDatasource {
  /// Merge-update when the active host switches kitchen (kitchen list flow).
  Future<void> mergeUpdateKitchenForHost({
    required String kitchenId,
    required String userId,
    required String kitchenName,
    required String role,
    required String invitationCode,
  });

  /// Full document set after creating a kitchen from home.
  Future<void> setKitchenDocumentForNewHost({
    required String kitchenId,
    required String userId,
    required String invitationCode,
    required String? kitchenName,
  });
}
