/// Store billing stub (backend subscription mode uses [NoOpBillingRepository]).
abstract interface class BillingRepository {
  Future<void> configureIfNeeded();

  Future<void> onUserSignedIn(String appUserId);

  Future<void> logOut();

  Future<void> restorePurchases({String? applicationUserName});
}
