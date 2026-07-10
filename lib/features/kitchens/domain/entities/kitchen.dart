class Kitchen {
  final String invitationCode;
  final String kitchenId;
  final String kitchenName;
  final String role;
  final String unitSystem;

  Kitchen({
    required this.invitationCode,
    required this.kitchenId,
    required this.kitchenName,
    required this.role,
    this.unitSystem = 'metric',
  });
}
