import 'package:hooks_riverpod/legacy.dart';

import 'package:networld/src/src/features/core/daily/ui/state_management/daily_rewards_state.dart';

/// Stub provider so [survey_gift_card.dart] still compiles; daily gift/missions logic removed.
final dailyRewardsProvider =
    StateNotifierProvider.autoDispose<DailyRewardsNotifier, DailyRewardsState>(
  (ref) => DailyRewardsNotifier(),
);

class DailyRewardsNotifier extends StateNotifier<DailyRewardsState> {
  DailyRewardsNotifier() : super(const DailyRewardsState());

  /// No-op (missions / claims removed).
  Future<void> loadAll() async {}

  /// Survey gift feature removed — always returns null.
  Future<int?> claimSurveyGift(String pollId) async => null;
}
