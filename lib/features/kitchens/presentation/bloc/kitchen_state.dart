import 'package:equatable/equatable.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';

abstract class KitchenState extends Equatable {
  const KitchenState();

  @override
  List<Object?> get props => [];
}

class KitchenInitial extends KitchenState {}

class KitchensLoading extends KitchenState {}

class KitchenFailure extends KitchenState {
  final String errorMessage;
  KitchenFailure(this.errorMessage);
}

class KitchenSuccess extends KitchenState {
  final String successMessage;
  KitchenSuccess(this.successMessage);
}

class KitchensLoaded extends KitchenState {
  final List<Kitchen> kitchens;

  const KitchensLoaded(this.kitchens);

  @override
  List<Object?> get props => [kitchens];
}
