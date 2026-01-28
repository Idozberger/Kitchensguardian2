class AppState {
  final bool fcmInitialized;

  const AppState({required this.fcmInitialized});

  const AppState.initial() : fcmInitialized = false;

  AppState copyWith({bool? fcmInitialized}) {
    return AppState(fcmInitialized: fcmInitialized ?? this.fcmInitialized);
  }
}
