import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetKitchenMembers
    implements UseCase<List<Member>, GetKitchenMembersParams> {
  final DashboardRepository dashboardRepository;
  const GetKitchenMembers(this.dashboardRepository);

  @override
  Future<Either<Failure, List<Member>>> call(
    GetKitchenMembersParams params,
  ) async {
    return await dashboardRepository.getKichenMembers(
      kitchenId: params.kitchenId,
    );
  }
}

class GetKitchenMembersParams {
  final String kitchenId;

  GetKitchenMembersParams({required this.kitchenId});
}
