sealed class PantryState {
  const PantryState();
}

final class PantryInitial extends PantryState {}

final class PantryLoading extends PantryState {}

class PantrySuccess extends PantryState {
  final String successMessage;
  PantrySuccess(this.successMessage);
}

class PantryFailure extends PantryState {
  final String errorMessage;
  PantryFailure(this.errorMessage);
}
