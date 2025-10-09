import 'package:equatable/equatable.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';

class KitchenState extends Equatable {
  final bool loadingKitchens;
  final bool loadingJoinedKitchens;
  final String? errorMessage;
  final String? successMessage;
  final List<KitchenModel>? kitchenList;

  const KitchenState({
    this.loadingKitchens = false,
    this.loadingJoinedKitchens = false,
    this.errorMessage,
    this.successMessage,
    this.kitchenList,
  });

  KitchenState copyWith({
    bool? loadingKitchens,
    bool? loadingJoinedKitchens,
    String? errorMessage,
    String? successMessage,
    List<KitchenModel>? kitchenList,
  }) {
    return KitchenState(
      loadingKitchens: loadingKitchens ?? this.loadingKitchens,
      loadingJoinedKitchens:
          loadingJoinedKitchens ?? this.loadingJoinedKitchens,
      errorMessage: errorMessage,
      successMessage: successMessage,
      kitchenList: kitchenList ?? this.kitchenList,
    );
  }

  @override
  List<Object?> get props => [
    loadingKitchens,
    errorMessage,
    successMessage,
    loadingJoinedKitchens,
    kitchenList,
  ];
}
