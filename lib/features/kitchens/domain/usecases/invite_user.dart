import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class InviteUser implements UseCase<String, InviteUserKitchenParams> {
  final KitchenRepository kitchenRepository;
  const InviteUser(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(InviteUserKitchenParams params) async {
    return await kitchenRepository.inviteUser(
      email: params.email,
      kitchenId: params.kitchenId,
    );
  }
}

class InviteUserKitchenParams {
  final String kitchenId;
  final String email;

  InviteUserKitchenParams({required this.kitchenId, required this.email});
}
