/// Safe copy for [SnackBar]s, dialogs, and bloc failure states.
///
/// Never show [cause] or [stackTrace] to end users — use [AppLogger] instead.
class UserFacingError {
  final String userMessage;
  final Object? cause;
  final StackTrace? stackTrace;

  const UserFacingError(this.userMessage, {this.cause, this.stackTrace});
}
