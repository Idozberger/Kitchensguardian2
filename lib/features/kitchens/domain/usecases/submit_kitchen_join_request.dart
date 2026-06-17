import 'dart:math';

import 'package:foodkitchen/core/services/fcm/fcm_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/kitchens/domain/datasources/kitchen_join_request_firestore_datasource.dart';
import 'package:intl/intl.dart';

class SubmitKitchenJoinRequestParams {
  final String invitationCode;
  final String senderUserId;
  final String senderFirstName;
  final String senderLastName;
  final bool checkPendingDuplicate;

  /// When true, FCM `data` uses invitation/name/role/kitchen from the host
  /// kitchen document. When false (e.g. home flow), uses [fcmInvitationCode]…
  final bool fcmMetadataFromHostKitchen;
  final String fcmInvitationCode;
  final String fcmKitchenName;
  final String fcmRole;
  final String fcmKitchenId;
  final bool includeApprovedByFieldInNotification;

  SubmitKitchenJoinRequestParams({
    required this.invitationCode,
    required this.senderUserId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.checkPendingDuplicate,
    required this.fcmMetadataFromHostKitchen,
    required this.fcmInvitationCode,
    required this.fcmKitchenName,
    required this.fcmRole,
    required this.fcmKitchenId,
    required this.includeApprovedByFieldInNotification,
  });
}

sealed class KitchenJoinRequestOutcome {}

class KitchenJoinInvalidInvitation extends KitchenJoinRequestOutcome {}

class KitchenJoinSenderIsHost extends KitchenJoinRequestOutcome {
  final String kitchenName;
  KitchenJoinSenderIsHost(this.kitchenName);
}

class KitchenJoinHostUserNotFound extends KitchenJoinRequestOutcome {}

class KitchenJoinPendingAlreadyExists extends KitchenJoinRequestOutcome {
  final String kitchenName;
  KitchenJoinPendingAlreadyExists(this.kitchenName);
}

class KitchenJoinHostDeviceTokenMissing extends KitchenJoinRequestOutcome {}

class KitchenJoinRequestSent extends KitchenJoinRequestOutcome {}

class KitchenJoinUnexpectedError extends KitchenJoinRequestOutcome {
  final Object error;
  final StackTrace? stackTrace;
  KitchenJoinUnexpectedError(this.error, [this.stackTrace]);
}

class SubmitKitchenJoinRequest {
  SubmitKitchenJoinRequest(this._firestore, {FCMService? fcm})
    : _fcm = fcm ?? FCMService();

  final KitchenJoinRequestFirestoreDatasource _firestore;
  final FCMService _fcm;

  Future<KitchenJoinRequestOutcome> call(
    SubmitKitchenJoinRequestParams p,
  ) async {
    try {
      final kitchenData = await _firestore.fetchKitchenByInvitationCode(
        p.invitationCode,
      );
      if (kitchenData == null) {
        return KitchenJoinInvalidInvitation();
      }

      final hostUserId = kitchenData['user_id'];
      final kitchenName = kitchenData['kitchen_name']?.toString() ?? '';
      final kitchenId = kitchenData['kitchen_id']?.toString() ?? '';

      if (p.senderUserId == hostUserId) {
        return KitchenJoinSenderIsHost(kitchenName);
      }

      final hostUser = await _firestore.fetchUserDocument(
        hostUserId.toString(),
      );
      if (hostUser == null) {
        return KitchenJoinHostUserNotFound();
      }

      if (p.checkPendingDuplicate) {
        final pending = await _firestore.hasPendingKitchenJoinRequest(
          senderUserId: p.senderUserId,
          kitchenId: kitchenId,
        );
        if (pending) {
          return KitchenJoinPendingAlreadyExists(kitchenName);
        }
      }

      final userDeviceToken = hostUser['user_device_token'];
      if (userDeviceToken == null ||
          (userDeviceToken is String && userDeviceToken.isEmpty)) {
        return KitchenJoinHostDeviceTokenMissing();
      }

      final tokenStr = userDeviceToken.toString();
      final notificationId = Random().nextInt(999999);
      final senderFullName = '${p.senderFirstName} ${p.senderLastName}'.trim();
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final body =
          'User ${p.senderFirstName} wants to join your kitchen: $kitchenName.';

      final notificationData = <String, dynamic>{
        'status': false,
        'id': notificationId,
        'title': 'Request to join your kitchen',
        'body': body,
        'host_user_id': hostUserId,
        'sender_user_id': p.senderUserId,
        'sender_name': senderFullName,
        'kitchen_id': kitchenData['kitchen_id'],
        'date': dateStr,
        'read': false,
        'kitchen_joining_status': 'Pending',
      };
      if (p.includeApprovedByFieldInNotification) {
        notificationData['approved_by'] = '';
      }

      devPrint('📦 Sending notification data: $notificationData');

      final fcmInv = p.fcmMetadataFromHostKitchen
          ? (kitchenData['invitation_code']?.toString() ?? '')
          : p.fcmInvitationCode;
      final fcmKitchen = p.fcmMetadataFromHostKitchen
          ? (kitchenData['kitchen_name']?.toString() ?? '')
          : p.fcmKitchenName;
      final fcmRole = p.fcmMetadataFromHostKitchen
          ? (kitchenData['role']?.toString() ?? '')
          : p.fcmRole;
      final fcmKid = p.fcmMetadataFromHostKitchen
          ? (kitchenData['kitchen_id']?.toString() ?? '')
          : p.fcmKitchenId;

      await _fcm.sendNotification(
        tokenStr,
        'Request to join your kitchen',
        body,
        fcmInv,
        fcmKitchen,
        fcmRole,
        fcmKid,
        'Pending',
      );

      await _firestore.addNotification(notificationData);

      return KitchenJoinRequestSent();
    } catch (e, st) {
      devPrint('🧾 Stack Trace: $st');
      return KitchenJoinUnexpectedError(e, st);
    }
  }
}
