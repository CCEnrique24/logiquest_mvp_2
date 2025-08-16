import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdsHelper {
  static const bannerId = BannerAd.testAdUnitId;
  static const interstitialId = InterstitialAd.testAdUnitId;
  static const rewardedId = RewardedAd.testAdUnitId;

  static BannerAd createBanner(void Function() onLoaded) {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerId,
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, err) {
          debugPrint('Banner error: $err');
          ad.dispose();
        },
      ),
      request: const AdRequest(nonPersonalizedAds: true),
    )..load();
  }

  static Future<void> showInterstitialIfAvailable(Function onShown) async {
    await InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(nonPersonalizedAds: true),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint('Interstitial show error: $err');
              ad.dispose();
            },
          );
          ad.show();
          onShown();
        },
        onAdFailedToLoad: (err) => debugPrint('Interstitial load error: $err'),
      ),
    );
  }

  static Future<void> showRewarded(void Function(RewardItem) onReward) async {
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(nonPersonalizedAds: true),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint('Rewarded show error: $err');
              ad.dispose();
            },
          );
          ad.show(onUserEarnedReward: (ad, reward) => onReward(reward));
        },
        onAdFailedToLoad: (err) => debugPrint('Rewarded load error: $err'),
      ),
    );
  }
}
