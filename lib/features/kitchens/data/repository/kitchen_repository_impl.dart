import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class KitchenRepositoryImpl implements KitchenRepository {
  final KitchenRemoteDatasource kitchenRemoteDataSource;
  KitchenRepositoryImpl(this.kitchenRemoteDataSource);
  @override
  Future<Either<Failure, List<KitchenModel>>> getKitchens() async {
    try {
      final response = await kitchenRemoteDataSource.getKitchens();

      final kitchens = (response as List)
          .map((e) => KitchenModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(kitchens);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
