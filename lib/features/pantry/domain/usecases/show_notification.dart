import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class ShowNotification implements UseCase<String, ShowNotificationParams> {
  final PantryRepository pantryRepository;
  const ShowNotification(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(ShowNotificationParams params) async {
    return await pantryRepository.showNotification(
      id: params.id,
      title: params.title,
      body: params.body,
      payload: params.payload,
    );
  }
}

class ShowNotificationParams {
  final int id;
  final String title;
  final String body;
  final String? payload;

  ShowNotificationParams({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
