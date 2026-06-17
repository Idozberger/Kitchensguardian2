import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/dashboard_join_request_firestore_datasource.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';

class ApproveKitchenJoinRequestParams {
  final String memberUserId;
  final String kitchenId;
  final int notificationLegacyId;
  final String hostUserId;
  final String hostFirstName;
  final String hostLastName;
  final String hostInvitationCode;
  final String hostKitchenName;
  final String hostActiveKitchenId;

  ApproveKitchenJoinRequestParams({
    required this.memberUserId,
    required this.kitchenId,
    required this.notificationLegacyId,
    required this.hostUserId,
    required this.hostFirstName,
    required this.hostLastName,
    required this.hostInvitationCode,
    required this.hostKitchenName,
    required this.hostActiveKitchenId,
  });
}

class ApproveKitchenJoinOutcome {
  final String invitationCode;
  final String approvedMemberUserId;

  ApproveKitchenJoinOutcome({
    required this.invitationCode,
    required this.approvedMemberUserId,
  });
}

class ApproveKitchenJoinRequest {
  ApproveKitchenJoinRequest(this._firestore, {FCMService? fcm})
    : _fcm = fcm ?? FCMService();

  final DashboardJoinRequestFirestoreDatasource _firestore;
  final FCMService _fcm;

  Future<Either<Failure, ApproveKitchenJoinOutcome>> call(
    ApproveKitchenJoinRequestParams p, {
    Future<void> Function(ApproveKitchenJoinOutcome outcome)?
    onAfterFcmBeforeFirestore,
  }) async {
    devLog('[approve] ${p.memberUserId}');

    final userData = await _firestore.fetchUserDocument(p.memberUserId);
    if (userData == null) {
      devLog('[approve] user not found');
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
      'title': 'You have been added to the kitchen',
      'body':
          'Your request to join the kitchen "$kitchenName" has been approved by the host. You are now added to the kitchen. You can access it anytime using this invitation code: $inviteCode',
      'host_user_id': p.memberUserId,
      'sender_user_id': p.hostUserId,
      'sender_name': senderName,
      'kitchen_id': p.kitchenId,
      'invitation_code': inviteCode,
      'date': nowStr,
      'read': false,
      'kitchen_joining_status': 'Approved',
      'approved_by': p.hostUserId,
    };

    final body =
        'Your request to join the kitchen "$kitchenName" has been approved by the host. You are now added to the kitchen. You can access it anytime using this invitation code: $inviteCode';

    await _fcm.sendNotification(
      tokenStr,
      'You have been added to the kitchen',
      body,
      p.hostInvitationCode,
      p.hostKitchenName,
      'member',
      p.hostActiveKitchenId,
      'Approved',
    );

    final outcome = ApproveKitchenJoinOutcome(
      invitationCode: inviteCode.toString(),
      approvedMemberUserId: p.memberUserId,
    );
    if (onAfterFcmBeforeFirestore != null) {
      await onAfterFcmBeforeFirestore(outcome);
    }

    await _firestore.addNotificationDocument(notificationData);
    await _firestore.patchJoinRequestNotification(
      kitchenId: p.kitchenId,
      senderUserId: p.memberUserId,
      updates: {
        'kitchen_joining_status': 'Approved',
        'status': true,
        'read': false,
      },
    );
    await _firestore.markNotificationsReadByLegacyIntId(p.notificationLegacyId);

    return Right(outcome);
  }
}
