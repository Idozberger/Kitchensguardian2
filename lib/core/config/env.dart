import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration from the `.env` asset (see repository `.env.example`).
class Env {
  Env._();

  static String get apiBaseUrl => dotenv.get('API_BASE_URL').trim();

  static String get googleSignInServerClientId =>
      dotenv.get('GOOGLE_SIGN_IN_SERVER_CLIENT_ID').trim();

  /// Paywall / Go Pro. Explicit `true`/`false` wins; when unset, enabled for backend mode.
  static bool get billingUiEnabled {
    final raw = dotenv.maybeGet('BILLING_UI_ENABLED')?.trim().toLowerCase();
    if (raw == '1' || raw == 'true' || raw == 'yes') {
      return true;
    }
    if (raw == '0' || raw == 'false' || raw == 'no') {
      return false;
    }
    return useBackendSubscription;
  }

  /// `backend` (default): plans + subscribe via API. `iap` reserved for future store billing.
  static bool get useBackendSubscription {
    final raw =
        dotenv.maybeGet('SUBSCRIPTION_BILLING_MODE')?.trim().toLowerCase() ??
        'backend';
    return raw != 'iap' && raw != 'store';
  }

  /// Release AdMob unit IDs (ignored in debug builds via [AdKeys]).
  static String get admobInterstitialAndroidRelease =>
      dotenv.maybeGet('ADMOB_INTERSTITIAL_ANDROID_RELEASE')?.trim() ?? '';

  static String get admobInterstitialIosRelease =>
      dotenv.maybeGet('ADMOB_INTERSTITIAL_IOS_RELEASE')?.trim() ?? '';

  static String get admobRewardedAndroidRelease =>
      dotenv.maybeGet('ADMOB_REWARDED_ANDROID_RELEASE')?.trim() ?? '';

  static String get firebaseProjectId =>
      dotenv.get('FIREBASE_PROJECT_ID').trim();

  static String get firebaseMessagingSenderId =>
      dotenv.get('FIREBASE_MESSAGING_SENDER_ID').trim();

  static String get firebaseStorageBucket =>
      dotenv.get('FIREBASE_STORAGE_BUCKET').trim();

  static FirebaseOptions get firebaseOptionsAndroid => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_ANDROID_API_KEY').trim(),
    appId: dotenv.get('FIREBASE_ANDROID_APP_ID').trim(),
    messagingSenderId: firebaseMessagingSenderId,
    projectId: firebaseProjectId,
    storageBucket: firebaseStorageBucket,
  );

  static FirebaseOptions get firebaseOptionsIos => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_IOS_API_KEY').trim(),
    appId: dotenv.get('FIREBASE_IOS_APP_ID').trim(),
    messagingSenderId: firebaseMessagingSenderId,
    projectId: firebaseProjectId,
    storageBucket: firebaseStorageBucket,
    androidClientId: dotenv.get('FIREBASE_IOS_ANDROID_CLIENT_ID').trim(),
    iosClientId: dotenv.get('FIREBASE_IOS_CLIENT_ID').trim(),
    iosBundleId: dotenv.get('FIREBASE_IOS_BUNDLE_ID').trim(),
  );

  /// Full FCM HTTP v1 URL, or derived from [firebaseProjectId].
  static String get fcmSendUrl {
    final full = dotenv.maybeGet('FCM_SEND_URL')?.trim();
    if (full != null && full.isNotEmpty) {
      return full;
    }
    return 'https://fcm.googleapis.com/v1/projects/$firebaseProjectId/messages:send';
  }

  static String get fcmServiceAccountAsset =>
      dotenv.maybeGet('FCM_SERVICE_ACCOUNT_ASSET')?.trim() ??
      'assets/services/service_account.json';
}
