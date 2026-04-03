import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_model.dart';
import 'package:brokies/src/src/features/core/daily/data/models/daily_poll_result_model.dart';
import 'package:brokies/src/src/features/core/poll/ui/widgets/poll_option_row.dart';

/// Shared layout for [DailyPollCard] and archived “Previous Pulses” polls.
class PulsePollCardView extends StatelessWidget {
  const PulsePollCardView({
    super.key,
    required this.poll,
    required this.results,
    required this.locale,
    this.titleAboveCard,
    this.readOnly = false,
    this.userVotedOptionId,
    this.isVoting = false,
    this.onOptionTap,
  });

  final DailyPollModel poll;
  final List<DailyPollResultModel> results;
  final Locale locale;

  /// When null, no title row is shown (e.g. items under “Previous Pulses”).
  final String? titleAboveCard;

  /// Archive mode: no voting, results shown like post-vote state.
  final bool readOnly;

  final int? userVotedOptionId;
  final bool isVoting;
  final void Function(int optionId)? onOptionTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final hasVoted = readOnly || userVotedOptionId != null;
    final totalVerified = results.fold<int>(0, (sum, r) => sum + r.verifiedCount);
    final totalVotes = results.fold<int>(0, (sum, r) => sum + r.votesCount);

    int? votesForOption(int id) {
      for (final r in results) {
        if (r.optionId == id) return r.votesCount;
      }
      return null;
    }

    num? avgNetWorthForOption(int id) {
      for (final r in results) {
        if (r.optionId == id) return r.avgNetWorth;
      }
      return null;
    }

    final dateLabel = poll.scheduledFor != null && readOnly
        ? DateFormat.yMMMd(locale.toString()).format(poll.scheduledFor!.toLocal())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleAboveCard != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleAboveCard!,
                style: theme.typo.displayXs.bold.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: UIColorsToken.pri550.withValues(alpha: 0.2),
              width: 1,
            ),
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
                      if (dateLabel != null) ...[
                        Text(
                          dateLabel,
                          style: theme.typo.textSm.medium.copyWith(
                            color: const Color(0xffFFD700).withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                            isSelected: !readOnly && userVotedOptionId == entry.id,
                            votesCount: votesForOption(entry.id),
                            avgNetWorth: avgNetWorthForOption(entry.id),
                            totalVotes: totalVotes > 0 ? totalVotes : null,
                            hasVoted: hasVoted,
                            onTap: readOnly || isVoting
                                ? null
                                : () => onOptionTap?.call(entry.id),
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
                            color: const Color(0xffFFD700).withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          if (hasVoted)
                            Text(
                              '$totalVerified Verified Voters',
                              style: theme.typo.textSm.regular.copyWith(
                                fontSize: 12,
                                color: const Color(0xffFFD700).withValues(alpha: 0.6),
                              ),
                            ).animate(effects: [FadeEffect()]),
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
