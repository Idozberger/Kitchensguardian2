import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  FCMService._privateConstructor();
  static final FCMService _instance = FCMService._privateConstructor();
  factory FCMService() => _instance;

  final Dio _dio = Dio();

  final String _serviceAccountPath = 'assets/services/service_account.json';

  final String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/kdasda-976c4/messages:send';

  Future<String> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(_serviceAccountPath);
      final jsonCredentials = json.decode(jsonString);

      final accountCredentials = ServiceAccountCredentials.fromJson(
        jsonCredentials,
      );

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final authClient = await clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      final accessToken = authClient.credentials.accessToken.data;

      authClient.close();
      return accessToken;
    } catch (e) {
      debugPrint(
        'Error reading service account or generating access token: $e',
      );
      rethrow;
    }
  }

  Future<void> sendNotification(
    String deviceToken,
    String title,
    String body,
    String invitationCode,
    String kitchenName,
    String role,
    String activeKitchenId,
    String status,
  ) async {
    try {
      final token = await _getAccessToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final payload = {
        'message': {
          'token': deviceToken,
          'notification': {'title': title, 'body': body},
          'data': {
            'title': title,
            'body': body,
            'type': 'kitchens_notification',
            'invitationCode': invitationCode,
            'kitchenName': kitchenName,
            'status': status,
            'role': role,

            'kitchenId': activeKitchenId,
          },
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'channel_id': 'high_importance_channel',
              'color': '#FF5722',
              'icon': 'ic_notification',
              'tag': 'kitchen_alert',
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'sound': 'default',
                'badge': 1,
                'content-available': 1,
                'mutable-content': 1,
                'category': 'KITCHEN_ALERT',
                'thread-id': 'kitchen_notifications',
              },
            },
          },
        },
      };

      final response = await _dio.post(
        _fcmUrl,
        data: json.encode(payload),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM notification sent successfully!');
      } else {
        debugPrint('Failed to send notification: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }
}
