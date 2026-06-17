import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:foodkitchen/core/config/env.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  FCMService._privateConstructor();
  static final FCMService _instance = FCMService._privateConstructor();
  factory FCMService() => _instance;

  final Dio _dio = Dio();

  String get _serviceAccountPath => Env.fcmServiceAccountAsset;

  String get _fcmUrl => Env.fcmSendUrl;

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
      devPrint('Error reading service account or generating access token: $e');
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
    String status, [
    String recipeId = "",
  ]) async {
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
            'recipeId': recipeId,
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

      final response = await _dio.post<dynamic>(
        _fcmUrl,
        data: json.encode(payload),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        devPrint('FCM notification sent successfully!');
      } else {
        devPrint('Failed to send notification: ${response.data}');
      }
    } catch (e) {
      devPrint('Error sending notification: $e');
    }
  }
}
