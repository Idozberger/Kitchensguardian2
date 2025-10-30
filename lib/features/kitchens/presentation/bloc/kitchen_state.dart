import 'package:equatable/equatable.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/users.dart';

abstract class KitchenState extends Equatable {
  const KitchenState();

  @override
  List<Object?> get props => [];
}

class KitchenInitial extends KitchenState {}

class KitchensLoading extends KitchenState {}

class KitchenFailure extends KitchenState {
  final String errorMessage;
  const KitchenFailure(this.errorMessage);
}

class KitchenSuccess extends KitchenState {
  final String successMessage;
  const KitchenSuccess(this.successMessage);
}

class KitchensLoaded extends KitchenState {
  final List<Kitchen> kitchens;

  const KitchensLoaded(this.kitchens);

  @override
  List<Object?> get props => [kitchens];
}

class AllUserLoaded extends KitchenState {
  final List<UserEntity> users;
  final String errorMessage;
  final String successMessage;
  final bool isLoading;
  final int index;

  const AllUserLoaded({
    this.users = const [],
    this.errorMessage = "",
    this.successMessage = "",
    this.isLoading = false,
    this.index = -1,
  });

  AllUserLoaded copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    int? index,
  }) {
    return AllUserLoaded(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? "",
      successMessage: successMessage ?? "",
      index: index ?? this.index,
    );
  }

  @override
  List<Object?> get props => [
    users,
    isLoading,
    index,
    errorMessage,
    successMessage,
  ];
}
