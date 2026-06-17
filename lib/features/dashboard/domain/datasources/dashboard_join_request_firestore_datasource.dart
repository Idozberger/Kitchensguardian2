/// Firestore I/O for kitchen join approve/decline flows only — no FCM or UI.
abstract class DashboardJoinRequestFirestoreDatasource {
  Future<Map<String, dynamic>?> fetchUserDocument(String userId);

  Future<Map<String, dynamic>?> fetchKitchenOwnedByHost({
    required String hostUserId,
    required String kitchenId,
  });

  Future<void> addNotificationDocument(Map<String, dynamic> data);

  Future<void> patchJoinRequestNotification({
    required String kitchenId,
    required String senderUserId,
    required Map<String, dynamic> updates,
  });

  Future<void> markNotificationsReadByLegacyIntId(int id);
}
