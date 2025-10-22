import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class MakeCohost implements UseCase<String, MakeCohostParams> {
  final DashboardRepository dashboardRepository;
  const MakeCohost(this.dashboardRepository);

  @override
  Future<Either<Failure, String>> call(MakeCohostParams params) async {
    return await dashboardRepository.makeCohost(
      kitchenId: params.kitchenId,
      memberId: params.memberId,
    );
  }
}

class MakeCohostParams {
  final String kitchenId;
  final String memberId;

  MakeCohostParams({required this.kitchenId, required this.memberId});
}
