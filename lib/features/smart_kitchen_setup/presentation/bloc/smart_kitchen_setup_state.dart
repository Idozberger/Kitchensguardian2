import 'package:foodkitchen/features/smart_kitchen_setup/data/models/kitchen_section_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/data/kitchen_section_data.dart';

class SmartKitchenSetupState {
  final bool isInitial;
  final bool isScanning;
  final bool isConfirmed;
  final bool isLoading;
  final bool isSkipping;
  final bool isFinalizing;
  final String? activeSectionId;
  final String? errorMessage;
  final String? skipSuccessMessage;
  final String? finalizeSuccessMessage;
  final String? sessionId;

  final List<KitchenSection> sections;
  final List<ScannedItemEntity> scannedItems;

  const SmartKitchenSetupState({
    required this.isInitial,
    required this.isScanning,
    required this.isConfirmed,
    required this.isLoading,
    required this.isSkipping,
    required this.isFinalizing,
    required this.sections,
    required this.scannedItems,
    this.skipSuccessMessage,
    this.finalizeSuccessMessage,
    this.sessionId,
    this.activeSectionId,
    this.errorMessage,
  });

  factory SmartKitchenSetupState.initial() {
    return SmartKitchenSetupState(
      isInitial: true,
      isScanning: false,
      isConfirmed: false,
      isLoading: false,
      isFinalizing: false,
      sections: kSections,
      scannedItems: [],
      isSkipping: false,
    );
  }

  int get completedCount => sections.where((s) => s.isComplete).length;
  bool get canConfirm => completedCount >= 2;
  double get progress =>
      sections.isEmpty ? 0 : completedCount / sections.length;

  Map<String, List<String>> get payload => {
    for (final s in sections)
      if (s.isComplete) s.id: s.imagePaths,
  };

  SmartKitchenSetupState copyWith({
    bool? isInitial,
    bool? isScanning,
    bool? isConfirmed,
    String? activeSectionId,
    String? errorMessage,
    bool clearError = false,
    bool? isSkipping,
    bool? isLoading,
    bool? isFinalizing,
    bool clearActiveSection = false,
    bool clearFinalizeSuccess = false,
    String? skipSuccessMessage,
    String? finalizeSuccessMessage,
    String? sessionId,
    List<KitchenSection>? sections,
    List<ScannedItemEntity>? scannedItems,
  }) {
    return SmartKitchenSetupState(
      skipSuccessMessage: skipSuccessMessage,
      finalizeSuccessMessage: clearFinalizeSuccess
          ? null
          : (finalizeSuccessMessage ?? this.finalizeSuccessMessage),
      sessionId: sessionId ?? this.sessionId,
      isInitial: isInitial ?? this.isInitial,
      isScanning: isScanning ?? this.isScanning,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
      isFinalizing: isFinalizing ?? this.isFinalizing,
      scannedItems: scannedItems ?? this.scannedItems,
      isSkipping: isSkipping ?? this.isSkipping,
      activeSectionId: clearActiveSection
          ? null
          : (activeSectionId ?? this.activeSectionId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
