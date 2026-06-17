import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/dashboard_join_request_firestore_datasource.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class DeclineKitchenJoinRequestParams {
  final String memberUserId;
  final String kitchenId;
  final int notificationLegacyId;
  final String hostUserId;
  final String hostFirstName;
  final String hostLastName;
  final String hostInvitationCode;
  final String hostKitchenName;
  final String hostActiveKitchenId;
  final String hostRole;

  DeclineKitchenJoinRequestParams({
    required this.memberUserId,
    required this.kitchenId,
    required this.notificationLegacyId,
    required this.hostUserId,
    required this.hostFirstName,
    required this.hostLastName,
    required this.hostInvitationCode,
    required this.hostKitchenName,
    required this.hostActiveKitchenId,
    required this.hostRole,
  });
}

class DeclineKitchenJoinRequest {
  DeclineKitchenJoinRequest(this._firestore, {FCMService? fcm})
    : _fcm = fcm ?? FCMService();

  final DashboardJoinRequestFirestoreDatasource _firestore;
  final FCMService _fcm;

  Future<Either<Failure, Unit>> call(DeclineKitchenJoinRequestParams p) async {
    final userData = await _firestore.fetchUserDocument(p.memberUserId);
    if (userData == null) {
      return const Left(Failure('User not found'));
    }

    final kitchenData = await _firestore.fetchKitchenOwnedByHost(
      hostUserId: p.hostUserId,
      kitchenId: p.kitchenId,
    );
    if (kitchenData == null) {
      return const Left(Failure('Kitchen not found'));
    }

    final inviteCode = kitchenData['invitation_code'] ?? '';
    final kitchenName = kitchenData['kitchen_name'] ?? '';
    final userDeviceToken = userData['user_device_token'];

    if (userDeviceToken == null ||
        (userDeviceToken is String && userDeviceToken.isEmpty)) {
      return const Left(Failure('User device token not found'));
    }

    final tokenStr = userDeviceToken.toString();
    final senderName = '${p.hostFirstName} ${p.hostLastName}'.trim();
    final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final notificationData = <String, dynamic>{
      'status': true,
      'title': 'Your request to join the kitchen was declined',
      'body':
          'Your request to join the kitchen "$kitchenName" has been declined by the host. You can try again later or contact the host for more details.',
      'host_user_id': p.memberUserId,
      'sender_user_id': p.hostUserId,
      'sender_name': senderName,
      'kitchen_id': p.kitchenId,
      'invitation_code': inviteCode,
      'date': nowStr,
      'read': false,
      'kitchen_joining_status': 'Declined',
      'approved_by': p.hostUserId,
    };

    final body =
        'Your request to join the kitchen "$kitchenName" has been declined by the host. You can try again later or contact the host for more details.';

    await _fcm.sendNotification(
      tokenStr,
      'Your request to join the kitchen was declined',
      body,
      p.hostInvitationCode,
      p.hostKitchenName,
      p.hostRole,
      p.hostActiveKitchenId,
      'Declined',
    );

    await _firestore.addNotificationDocument(notificationData);
    await _firestore.patchJoinRequestNotification(
      kitchenId: p.kitchenId,
      senderUserId: p.memberUserId,
      updates: {
        'kitchen_joining_status': 'Declined',
        'status': true,
        'read': false,
      },
    );
    await _firestore.markNotificationsReadByLegacyIntId(p.notificationLegacyId);

    return right(unit);
  }
}
