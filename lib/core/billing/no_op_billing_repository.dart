import 'package:foodkitchen/core/billing/billing_repository.dart';

/// No store billing — premium comes from the backend API ([SubscriptionRemoteDatasource]).
final class NoOpBillingRepository implements BillingRepository {
  @override
  Future<void> configureIfNeeded() async {}

  @override
  Future<void> logOut() async {}

  @override
  Future<void> onUserSignedIn(String appUserId) async {}

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}
}
