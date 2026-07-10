import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/ads/ad_loading_widget.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_keys.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();
  late AdKeys _keys;

  InterstitialAd? _interstitialAd;

  Future<void> initialize() async {
    _keys = AdKeys();
    await MobileAds.instance.initialize();
  }

  AdRequest get _request => const AdRequest();

  String get _interstitialAdUnitId => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _keys.interstitialIos,
    _ => _keys.interstitialAndroid,
  };

  Future<void> loadAndShowInterstitial({
    required BuildContext context,
    VoidCallback? onDismissed,
  }) async {
    final unitId = _interstitialAdUnitId;
    if (unitId.isEmpty) {
      devLog(
        'Interstitial skipped: release ad unit ID is missing in .env',
        name: 'Ads',
      );
      onDismissed?.call();
      return;
    }

    _showLoadingDialog(context);

    InterstitialAd.load(
      adUnitId: unitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) async {
          _interstitialAd = ad;
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          await _show(onDismissed: onDismissed);
        },
        onAdFailedToLoad: (error) {
          _logAdFailure('load', error);
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          // Code 3 = NO_FILL: no inventory; continue the user flow without an ad.
          onDismissed?.call();
        },
      ),
    );
  }

  void _logAdFailure(String phase, AdError error) {
    devLog(
      'Interstitial $phase failed: code=${error.code} '
      '(${_adErrorLabel(error.code)}) message=${error.message}',
      name: 'Ads',
    );
  }

  String _adErrorLabel(int code) {
    return switch (code) {
      0 => 'INTERNAL_ERROR',
      1 => 'INVALID_REQUEST',
      2 => 'NETWORK_ERROR',
      3 => 'NO_FILL',
      _ => 'UNKNOWN',
    };
  }

  Future<void> _show({VoidCallback? onDismissed}) async {
    if (_interstitialAd == null) {
      onDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logAdFailure('show', error);
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdLoadingDialog(),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
