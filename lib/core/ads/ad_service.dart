import 'package:flutter/material.dart';
import 'package:foodkitchen/core/ads/ad_loading_widget.dart';
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

  Future<void> loadAndShowInterstitial({
    required BuildContext context,
    VoidCallback? onDismissed,
  }) async {
    _showLoadingDialog(context);

    InterstitialAd.load(
      adUnitId: _keys.interstitialAndroid,
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
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      ),
    );
  }

  Future<void> _show({VoidCallback? onDismissed}) async {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdLoadingDialog(),
    );
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
