/// Store product IDs — must match App Store Connect, Google Play Console, and `verify-iap`.
abstract final class ShopProductIds {
  static const credits1000 = 'com.brokies.credits_1000';
  static const credits5000 = 'com.brokies.credits_5000';
  static const credits15000 = 'com.brokies.credits_15000';
  static const credits50000 = 'com.brokies.credits_50000';
  static const credits150000 = 'com.brokies.credits_150000';

  static const subSilver = 'com.brokies.sub.silver';
  static const subGold = 'com.brokies.sub.gold';
  static const subDiamond = 'com.brokies.sub.diamond';

  static const Set<String> consumableIds = {
    credits1000,
    credits5000,
    credits15000,
    credits50000,
    credits150000,
  };

  static const Set<String> subscriptionIds = {
    subSilver,
    subGold,
    subDiamond,
  };

  static Set<String> get all => {...consumableIds, ...subscriptionIds};

  static const Map<String, int> creditsByProductId = {
    credits1000: 1000,
    credits5000: 5000,
    credits15000: 15000,
    credits50000: 50000,
    credits150000: 150000,
  };

  static bool isSubscription(String productId) =>
      subscriptionIds.contains(productId);
}
