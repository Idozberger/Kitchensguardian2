List<Map<String, dynamic>> filterNotificationsByActiveKitchen(
  List<Map<String, dynamic>> items,
  String activeKitchenId,
) {
  return items.where((data) {
    final status = data['status'] ?? false;
    final kitchenId = data['kitchen_id'];
    if (status == true) return true;
    return kitchenId == activeKitchenId;
  }).toList();
}
