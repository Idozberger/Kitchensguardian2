import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` at the repo root (bundled as a Flutter asset).
class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('AppEnv: .env not loaded ($e); using built-in defaults.');
    }
  }

  static String _string(String key, String fallback) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) return fallback;
    return value;
  }

  static bool _bool(String key, {required bool fallback}) {
    final value = dotenv.env[key]?.trim().toLowerCase();
    if (value == null || value.isEmpty) return fallback;
    return value == 'true' || value == '1' || value == 'yes';
  }

  static String get apiBaseUrl =>
      _string('API_BASE_URL', 'https://web-production-c7f89.up.railway.app');

  static String get googleSignInServerClientId => _string(
        'GOOGLE_SIGN_IN_SERVER_CLIENT_ID',
        '295968556562-3e8sicsicb6m6kh744bon398o8gaqu3k.apps.googleusercontent.com',
      );

  static bool get billingUiEnabled => _bool('BILLING_UI_ENABLED', fallback: true);

  static String get subscriptionBillingMode =>
      _string('SUBSCRIPTION_BILLING_MODE', 'backend');

  static String get admobInterstitialAndroidRelease =>
      _string('ADMOB_INTERSTITIAL_ANDROID_RELEASE', '');

  static String get admobRewardedAndroidRelease =>
      _string('ADMOB_REWARDED_ANDROID_RELEASE', '');

  static String get firebaseProjectId =>
      _string('FIREBASE_PROJECT_ID', 'kdasda-976c4');

  static String get firebaseMessagingSenderId =>
      _string('FIREBASE_MESSAGING_SENDER_ID', '295968556562');

  static String get firebaseStorageBucket =>
      _string('FIREBASE_STORAGE_BUCKET', 'kdasda-976c4.firebasestorage.app');

  static String get firebaseAndroidApiKey => _string(
        'FIREBASE_ANDROID_API_KEY',
        'AIzaSyDLCH82A3mYQgQVqApFzqF81LivETUppn4',
      );

  static String get firebaseAndroidAppId => _string(
        'FIREBASE_ANDROID_APP_ID',
        '1:295968556562:android:e593b0946516734e08facb',
      );

  static String get firebaseIosApiKey => _string(
        'FIREBASE_IOS_API_KEY',
        'AIzaSyCqHwPntnQVxyzJFFKrfB2raMNgzPRtAh8',
      );

  static String get firebaseIosAppId => _string(
        'FIREBASE_IOS_APP_ID',
        '1:295968556562:ios:412f970fec3d4eec08facb',
      );

  static String get firebaseIosAndroidClientId => _string(
        'FIREBASE_IOS_ANDROID_CLIENT_ID',
        '295968556562-o7c8lrqj1tfup8j5c8fb0868gv2or5ek.apps.googleusercontent.com',
      );

  static String get firebaseIosClientId => _string(
        'FIREBASE_IOS_CLIENT_ID',
        '295968556562-4acvanbd77neqo4govbof4rm8d6ht3mh.apps.googleusercontent.com',
      );

  static String get firebaseIosBundleId =>
      _string('FIREBASE_IOS_BUNDLE_ID', 'com.itz.kitchens.guardian');

  static String get fcmSendUrl => _string(
        'FCM_SEND_URL',
        'https://fcm.googleapis.com/v1/projects/$firebaseProjectId/messages:send',
      );

  static String get fcmServiceAccountAsset =>
      _string('FCM_SERVICE_ACCOUNT_ASSET', 'assets/services/service_account.json');

  static FirebaseOptions get androidFirebaseOptions => FirebaseOptions(
        apiKey: firebaseAndroidApiKey,
        appId: firebaseAndroidAppId,
        messagingSenderId: firebaseMessagingSenderId,
        projectId: firebaseProjectId,
        storageBucket: firebaseStorageBucket,
      );

  static FirebaseOptions get iosFirebaseOptions => FirebaseOptions(
        apiKey: firebaseIosApiKey,
        appId: firebaseIosAppId,
        messagingSenderId: firebaseMessagingSenderId,
        projectId: firebaseProjectId,
        storageBucket: firebaseStorageBucket,
        androidClientId: firebaseIosAndroidClientId,
        iosClientId: firebaseIosClientId,
        iosBundleId: firebaseIosBundleId,
      );
}
