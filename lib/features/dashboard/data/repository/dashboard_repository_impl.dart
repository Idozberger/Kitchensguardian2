import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/dashboard/data/datasource/dashboard_remote_datasource.dart';
import 'package:foodkitchen/features/dashboard/data/model/member_model.dart';

import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource dashboardRemoteDatasource;
  DashboardRepositoryImpl(this.dashboardRemoteDatasource);

  @override
  Future<Either<Failure, List<Member>>> getKichenMembers({
    required String kitchenId,
  }) async {
    try {
      final response = await dashboardRemoteDatasource.getKitchenMembers(
        kitchenId: kitchenId,
      );

      final members = response
          .map<MemberModel>((member) => MemberModel.fromJson(member))
          .toList();

      return Right(members);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> kickMember({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dashboardRemoteDatasource.kickMember(
        kitchenId: kitchenId,
        memberId: memberId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> makeCohost({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dashboardRemoteDatasource.makeCohost(
        kitchenId: kitchenId,
        memberId: memberId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
