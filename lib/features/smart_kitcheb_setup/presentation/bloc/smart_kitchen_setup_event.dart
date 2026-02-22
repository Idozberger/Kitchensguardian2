import 'package:foodkitchen/features/smart_kitcheb_setup/data/models/kitchen_section_model.dart';

sealed class SmartKitchenSetupEvent {}

final class SmartKitchenSetupStarted extends SmartKitchenSetupEvent {}

final class SmartKitchenSetupScanRequested extends SmartKitchenSetupEvent {
  final KitchenSection section;
  SmartKitchenSetupScanRequested(this.section);
}

final class SmartKitchenSetupSectionCleared extends SmartKitchenSetupEvent {
  final KitchenSection section;
  SmartKitchenSetupSectionCleared(this.section);
}

final class SmartKitchenSetupConfirmed extends SmartKitchenSetupEvent {
  final String kitchenId;
  SmartKitchenSetupConfirmed(this.kitchenId);
}

final class SmartKitchenSetupApiCalled extends SmartKitchenSetupEvent {
  final String kitchenId;
  final Map<String, List<String>> payload;
  SmartKitchenSetupApiCalled({required this.kitchenId, required this.payload});
}

final class SkipKitchenSetupEvent extends SmartKitchenSetupEvent {
  final String kitchenId;

  SkipKitchenSetupEvent({required this.kitchenId});
}
