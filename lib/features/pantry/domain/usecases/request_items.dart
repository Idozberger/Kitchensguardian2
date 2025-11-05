import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class RequestItems implements UseCase<String, RequestItemsParams> {
  final PantryRepository pantryRepository;
  const RequestItems(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(RequestItemsParams params) async {
    return await pantryRepository.requestItems(pantry: params.pantry);
  }
}

class RequestItemsParams {
  final Pantry pantry;

  RequestItemsParams({required this.pantry});
}
