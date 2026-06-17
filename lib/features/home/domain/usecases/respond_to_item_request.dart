import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class RespondToItemRequest
    implements UseCase<String, RespondToItemRequestParams> {
  final HomeRepository kitchenRepository;
  const RespondToItemRequest(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(
    RespondToItemRequestParams params,
  ) async {
    return await kitchenRepository.respondToItemRequest(
      action: params.action,
      rejectReason: params.rejectReason,
      requestId: params.requestId,
    );
  }
}

class RespondToItemRequestParams {
  final String action;
  final String rejectReason;
  final String requestId;

  RespondToItemRequestParams({
    required this.action,
    required this.rejectReason,
    required this.requestId,
  });
}
