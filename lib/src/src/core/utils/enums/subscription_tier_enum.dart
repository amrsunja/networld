/// Mirrors Postgres `subscription_tier_enum` (profiles.subscription_tier).
enum SubscriptionTier {
  none,
  silver,
  gold,
  diamond;

  static SubscriptionTier fromDb(String? value) {
    switch (value) {
      case 'silver':
        return SubscriptionTier.silver;
      case 'gold':
        return SubscriptionTier.gold;
      case 'diamond':
        return SubscriptionTier.diamond;
      default:
        return SubscriptionTier.none;
    }
  }

  String get dbValue => name;

  /// Discount on post/comment credit costs (0–100). Server must re-apply when charging.
  int get postDiscountPercent {
    switch (this) {
      case SubscriptionTier.silver:
        return 25;
      case SubscriptionTier.gold:
        return 50;
      case SubscriptionTier.diamond:
        return 75;
      case SubscriptionTier.none:
        return 0;
    }
  }

  bool get isActive => this != SubscriptionTier.none;
}
