import 'package:foodkitchen/features/kitchens/domain/entities/join_request_info.dart';

abstract class KitchenJoinStatusFirestoreDatasource {
  Stream<List<JoinRequestInfo>> watchPendingJoinRequestsForSender(
    String userId,
  );
}
