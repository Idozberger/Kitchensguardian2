abstract class DashboardNotificationsFirestoreDatasource {
  Stream<List<Map<String, dynamic>>> watchNotificationsForHost(
    String hostUserId,
  );
}
