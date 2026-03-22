import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_provider.dart';
import 'package:networld/src/src/features/core/poll/ui/widgets/poll_option_row.dart';
import 'package:networld/src/src/features/settings/ui/state_management/settings_provider.dart';

class DailyPollCard extends ConsumerWidget {
  const DailyPollCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final state = ref.watch(dailyProvider);
    final notifier = ref.read(dailyProvider.notifier);
    final poll = state.poll;
    final hasVoted = state.userVotedOptionId != null;
    final results = state.results;
    final totalVerified = results.fold<int>(
      0,
      (sum, r) => sum + r.verifiedCount,
    );
    final totalVotes = results.fold<int>(0, (sum, r) => sum + r.votesCount);

    if (poll == null) {
      return const SizedBox.shrink();
    }

    final locale = ref.watch(settingsProvider).data?.locale ?? L10n.defaultLocale;

    int? votesForOption(int id) {
      for (final r in results) {
        if (r.optionId== id) return r.votesCount;
      }
      return null;
    }

    num? avgNetWorthForOption(int id) {
      for (final r in results) {
        if (r.optionId== id) return r.avgNetWorth;
      }
      return null;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Pulse",
              style: theme.typo.displayXs.bold.copyWith(
                color: UIColorsToken.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: UIColorsToken.pri550.withValues(alpha: 0.2),
              width: 1
            )
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                if (poll.imageUrl != null && poll.imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: UIImage.network(
                      image: poll.imageUrl!,
                      boxFit: BoxFit.cover,
                    ),
                  )
                else
                  Positioned.fill(
                    child: Container(color: theme.colors.cardColor),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          UIColorsToken.black.withValues(alpha: 0.6),
                          UIColorsToken.black.withValues(alpha: 0.9),
                          UIColorsToken.black,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        poll.question,
                        style: theme.typo.displaySm.bold.copyWith(
                          color: theme.colors.contentColor,
                        ),
                      ),

                      const SizedBox(height: 24),
                      ...?poll.options?.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: PollOptionRow(
                            option: entry,
                            locale: locale,
                            isSelected: state.userVotedOptionId == entry.id,
                            votesCount: votesForOption(entry.id),
                            avgNetWorth: avgNetWorthForOption(entry.id),
                            totalVotes: totalVotes > 0 ? totalVotes : null,
                            hasVoted: hasVoted,
                            onTap: state.isVoting ? null : () => notifier.castVote(entry.id),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_rounded,
                            size: 20,
                            color: Color(0xffFFD700).withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),

                          if (hasVoted)
                            Text(
                              '$totalVerified Verified Voters',
                              style: theme.typo.textSm.regular.copyWith(
                                fontSize: 12,
                                color: Color(0xffFFD700).withValues(alpha: 0.6),
                              ),
                            ).animate(effects: [FadeEffect()])
                        ],
                      ).animate(effects: [FadeEffect()]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
