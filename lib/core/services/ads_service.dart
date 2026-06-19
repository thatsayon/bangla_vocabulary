import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

class AdsService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) return AppConstants.bannerAdUnitIdAndroid;
    return AppConstants.bannerAdUnitIdIOS;
  }

  static String get nativeAdUnitId => AppConstants.nativeAdUnitIdAndroid;
  static String get rewardedAdUnitId => AppConstants.rewardedAdUnitIdAndroid;

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed: $error');
          ad.dispose();
        },
      ),
    );
  }

  static void loadRewardedAd({
    required Function(RewardedAd ad) onLoaded,
    VoidCallback? onFailed,
  }) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed: $error');
          onFailed?.call();
        },
      ),
    );
  }
}
