import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class DemoteCohost implements UseCase<String, DemoteCohostParams> {
  final DashboardRepository dashboardRepository;
  const DemoteCohost(this.dashboardRepository);

  @override
  Future<Either<Failure, String>> call(DemoteCohostParams params) async {
    return await dashboardRepository.demoteCohost(
      kitchenId: params.kitchenId,
      memberId: params.memberId,
    );
  }
}

class DemoteCohostParams {
  final String kitchenId;
  final String memberId;

  DemoteCohostParams({required this.kitchenId, required this.memberId});
}
