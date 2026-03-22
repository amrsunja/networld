/*import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_rewards_provider.dart';

enum SurveyGiftStatus { mustVoteFirst, canClaim, alreadyClaimed, expired }

class SurveyGiftCard extends HookConsumerWidget {
  const SurveyGiftCard({
    super.key,
    required this.hasVotedToday,
    required this.giftClaimed,
    required this.pollId,
    required this.isExpired,
  });

  final bool hasVotedToday;
  final bool giftClaimed;
  final String? pollId;
  final bool isExpired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final rewardsState = ref.watch(dailyRewardsProvider);
    final rewardsNotifier = ref.read(dailyRewardsProvider.notifier);
    final appEvents = ref.read(appEventProvider);

    final isClaimed = giftClaimed;
    final isClaiming = rewardsState.isClaimingGift;
    final status = _computeSurveyGiftStatus(
      hasVotedToday: hasVotedToday,
      giftClaimed: giftClaimed,
      isExpired: isExpired,
    );
    final canClaim = status == SurveyGiftStatus.canClaim && !isClaiming;

    final countdown = useMemoized(() => _countdownToTwenty(), []);
    final countdownStr = useStream(countdown).data ?? '00:00:00';

    String buttonTitle;
    bool buttonDisabled;
    switch (status) {
      case SurveyGiftStatus.mustVoteFirst:
        buttonTitle = "Votez d'abord";
        buttonDisabled = true;
        break;
      case SurveyGiftStatus.canClaim:
        buttonTitle = 'Claim';
        buttonDisabled = false;
        break;
      case SurveyGiftStatus.alreadyClaimed:
        buttonTitle = 'Réclamé ✓';
        buttonDisabled = true;
        break;
      case SurveyGiftStatus.expired:
        buttonTitle = 'Expiré';
        buttonDisabled = true;
        break;
    }

    final isCompletedState = isClaimed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: UIColorsToken.pri550.withValues(alpha: 0.1),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            UIColorsToken.pri550.withValues(alpha: 0.1),
            UIColorsToken.pri350.withValues(alpha: 0.25),
            UIColorsToken.pri550.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UIColorsToken.pri350,
                  UIColorsToken.sec500
                ],
              ),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: UIColorsToken.black,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCompletedState ? l10n.dailySurveyGiftClaimed : l10n.dailySurveyOfTheDay,
                  style: theme.typo.textLg.semibold.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
                if (!isCompletedState) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: UIColorsToken.pri400,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        countdownStr,
                        style: theme.typo.textSm.regular.copyWith(
                          color: UIColorsToken.pri400,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isCompletedState) ...[
            const SizedBox(width: 12),
            SizedBox(
              height: 44,
              child: UIButton.primary(
                title: buttonTitle,
                disabled: buttonDisabled,
                isBusy: isClaiming,
                height: 44,
                customRadius: 12,
                onTap: canClaim && pollId != null
                    ? () async {
                        final credits = await rewardsNotifier.claimSurveyGift(pollId!);
                        if (credits != null && context.mounted) {
                          appEvents.send(
                            ShowSuccessMessageEvent(
                              '+$credits crédits',
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  SurveyGiftStatus _computeSurveyGiftStatus({
    required bool hasVotedToday,
    required bool giftClaimed,
    required bool isExpired,
  }) {
    if (!hasVotedToday) return SurveyGiftStatus.mustVoteFirst;
    if (giftClaimed) return SurveyGiftStatus.alreadyClaimed;
    if (isExpired) return SurveyGiftStatus.expired;
    return SurveyGiftStatus.canClaim;
  }

  static Stream<String> _countdownToTwenty() async* {
    while (true) {
      final now = DateTime.now();
      var target = DateTime(now.year, now.month, now.day, 20, 0, 0);
      if (now.isAfter(target)) {
        target = target.add(const Duration(days: 1));
      }
      final diff = target.difference(now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;
      yield '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}
*/
