import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/planner/domain/datasources/recipe_start_request_firestore_datasource.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class SubmitRecipeStartRequestParams {
  final String kitchenId;
  final String recipeId;
  final String recipeName;
  final String memberUserId;
  final String memberFirstName;
  final String memberLastName;

  SubmitRecipeStartRequestParams({
    required this.kitchenId,
    required this.recipeId,
    required this.recipeName,
    required this.memberUserId,
    required this.memberFirstName,
    required this.memberLastName,
  });
}

class SubmitRecipeStartRequest {
  SubmitRecipeStartRequest(this._firestore, {FCMService? fcm})
    : _fcm = fcm ?? FCMService();

  final RecipeStartRequestFirestoreDatasource _firestore;
  final FCMService _fcm;

  Future<Either<Failure, Unit>> call(SubmitRecipeStartRequestParams p) async {
    final kitchenData = await _firestore.fetchKitchenByKitchenId(p.kitchenId);
    if (kitchenData == null) {
      return const Left(Failure('Kitchen not found'));
    }
    devLog('kitchenId: $kitchenData');

    final hostUserId = kitchenData['user_id']?.toString() ?? '';
    final kitchenName = kitchenData['kitchen_name'] ?? '';
    final invitationCode = kitchenData['invitation_code'] ?? '';

    final hostDoc = await _firestore.fetchUserDocument(hostUserId);
    if (hostDoc == null) {
      return const Left(Failure('Host not found'));
    }

    final hostDeviceToken = hostDoc['user_device_token'];
    if (hostDeviceToken == null ||
        (hostDeviceToken is String && hostDeviceToken.isEmpty)) {
      return const Left(Failure('Host device token not found'));
    }

    final memberName = '${p.memberFirstName} ${p.memberLastName}'.trim();
    final body =
        '$memberName is requesting to start the recipe "${p.recipeName}" in the kitchen "$kitchenName".';

    final notificationData = <String, dynamic>{
      'status': false,
      'recipe_status': 'Pending',
      'title': 'Recipe Start Request',
      'body': body,
      'host_user_id': hostUserId,
      'sender_user_id': p.memberUserId,
      'sender_name': memberName,
      'kitchen_id': p.kitchenId,
      'recipe_id': p.recipeId,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'read': false,
      'notification_type': 'start_recipe_request',
    };

    await _fcm.sendNotification(
      hostDeviceToken.toString(),
      'Recipe Start Request',
      body,
      invitationCode.toString(),
      kitchenName.toString(),
      'host',
      p.kitchenId,
      'start_recipe_request',
      p.recipeId,
    );

    await _firestore.addRecipeStartRequest(notificationData);

    return right(unit);
  }
}
