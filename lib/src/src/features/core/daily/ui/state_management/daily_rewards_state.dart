/// Minimal state for [survey_gift_card.dart] (widget kept in repo but feature disabled app-wide).
class DailyRewardsState {
  const DailyRewardsState({
    this.isClaimingGift = false,
  });

  final bool isClaimingGift;

  DailyRewardsState copyWith({
    bool? isClaimingGift,
  }) {
    return DailyRewardsState(
      isClaimingGift: isClaimingGift ?? this.isClaimingGift,
    );
  }
}
