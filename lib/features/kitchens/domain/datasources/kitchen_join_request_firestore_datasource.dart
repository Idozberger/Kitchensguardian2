/// Firestore reads/writes for “member requests to join a kitchen” flows.
abstract class KitchenJoinRequestFirestoreDatasource {
  Future<Map<String, dynamic>?> fetchKitchenByInvitationCode(
    String invitationCode,
  );

  Future<Map<String, dynamic>?> fetchUserDocument(String userId);

  Future<bool> hasPendingKitchenJoinRequest({
    required String senderUserId,
    required String kitchenId,
  });

  Future<void> addNotification(Map<String, dynamic> data);
}
