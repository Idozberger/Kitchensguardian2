import 'package:flutter/foundation.dart';

abstract class AdKeys {
  String get interstitialAndroid;
  String get rewardedAndroid;

  factory AdKeys() => kDebugMode ? DebugAdKeys() : ReleaseAdKeys();
}

class DebugAdKeys implements AdKeys {
  @override
  String get interstitialAndroid => 'ca-app-pub-3940256099942544/1033173712';
  @override
  String get rewardedAndroid => 'ca-app-pub-3940256099942544/5224354917';
}

class ReleaseAdKeys implements AdKeys {
  @override
  String get interstitialAndroid => '';
  @override
  String get rewardedAndroid => '';
}
