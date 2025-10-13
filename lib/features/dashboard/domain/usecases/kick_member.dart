import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class KickMember implements UseCase<String, KickMemberParams> {
  final DashboardRepository dashboardRepository;
  const KickMember(this.dashboardRepository);

  @override
  Future<Either<Failure, String>> call(KickMemberParams params) async {
    return await dashboardRepository.kickMember(
      kitchenId: params.kitchenId,
      memberId: params.memberId,
    );
  }
}

class KickMemberParams {
  final String kitchenId;
  final String memberId;

  KickMemberParams({required this.kitchenId, required this.memberId});
}
