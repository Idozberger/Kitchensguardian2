/// Process-wide feature-access flag for non-UI layers (e.g. planner local storage).
///
/// Separate from [UserState.isPremiumUser], which reflects subscription status for UI.
final class UserEntitlementSnapshot {
  bool hasPremiumAccess = true;
}
