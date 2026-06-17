import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/config/env.dart';

abstract class AdKeys {
  String get interstitialAndroid;
  String get interstitialIos;
  String get rewardedAndroid;

  factory AdKeys() => kDebugMode ? DebugAdKeys() : ReleaseAdKeys();
}

class DebugAdKeys implements AdKeys {
  @override
  String get interstitialAndroid => 'ca-app-pub-3940256099942544/1033173712';

  @override
  String get interstitialIos => 'ca-app-pub-3940256099942544/4411468910';

  @override
  String get rewardedAndroid => 'ca-app-pub-3940256099942544/5224354917';
}

class ReleaseAdKeys implements AdKeys {
  @override
  String get interstitialAndroid => Env.admobInterstitialAndroidRelease;

  @override
  String get interstitialIos => Env.admobInterstitialIosRelease;

  @override
  String get rewardedAndroid => Env.admobRewardedAndroidRelease;
}
