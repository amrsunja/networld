import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/features/core/poll/data/models/poll_option_model.dart';

class PollOptionRow extends StatelessWidget {
  final PollOptionModel option;
  final Locale locale;
  final bool isSelected;
  final int? votesCount;
  final num? avgNetWorth;
  final int? totalVotes;
  final bool hasVoted;
  final VoidCallback? onTap;

  const PollOptionRow({
    super.key,
    required this.option,
    required this.locale,
    required this.isSelected,
    this.votesCount,
    this.avgNetWorth,
    this.totalVotes,
    required this.hasVoted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final canTap = !hasVoted && onTap != null;

    final bool hasValidVotes =
        totalVotes != null && totalVotes! > 0 && votesCount != null;

    final percentage =
        hasValidVotes ? (votesCount! / totalVotes! * 100).round() : 0;

    final progress =
        hasValidVotes ? (votesCount! / totalVotes!).clamp(0.0, 1.0) : 0.0;

    final titleStyle = theme.typo.textLg.bold.copyWith(
      color: isSelected ? UIColorsToken.pri350 : UIColorsToken.white,
      shadows: isSelected ? [
        Shadow(
          color: UIColorsToken.pri500.withValues(alpha: 0.5),
          blurRadius: 10
        )
      ] : null,
    );

    final percenteStyle = theme.typo.textLg.bold.copyWith(
      color: isSelected ? UIColorsToken.pri350 : Color(0xff94A3B8),
      shadows: isSelected ? [
        Shadow(
          color: UIColorsToken.pri500.withValues(alpha: 0.5),
          blurRadius: 10
        )
      ] : null,
    );

    final subtitleStyle = theme.typo.textSm.semibold.copyWith(
      color: isSelected ? Color(0xffFFD700).withValues(alpha: 0.7) : Color(0xff94A3B8)
    );


    final borderRadius = BorderRadius.circular(12);

    return UITap(
      onTap: canTap ? onTap : null,
      child: Stack(
        children: [
          // Progress background bar
          Positioned.fill(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth * progress;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.fastOutSlowIn,
                      height: constraints.maxHeight,
                      width: width,
                      decoration: BoxDecoration(
                        color: (isSelected ? UIColorsToken.pri350 : UIColorsToken.white).withValues(alpha: 0.08),
                        borderRadius: borderRadius,
                        border: Border(
                          right: BorderSide(
                            color: isSelected
                                ? const Color(0xffFFD700).withValues(alpha: 0.5)
                                : UIColorsToken.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Foreground content with border
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? const Color(0xffFFD700).withValues(alpha: 0.5)
                    : UIColorsToken.white.withValues(alpha: 0.1),
              ),
              borderRadius: borderRadius,
              color: isSelected
                  ? UIColorsToken.pri350.withValues(alpha: 0.05)
                  : UIColorsToken.black.withValues(alpha: 0.03),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text(
                        option.titleFor(locale),
                        style: titleStyle,
                      ),
                      Text(
                        hasVoted 
                          ? _formatAvgNetWorth(avgNetWorth ?? 0)
                          : 'Vote to see Avg Voter NW',
                        style: subtitleStyle,
                      ),
                    ],
                  ),
                ),
                if (hasVoted)
                  Text(
                    '$percentage%',
                    style: percenteStyle,
                  ).animate(effects: [FadeEffect()]),
              ],
            ),
          ),
        ],
      ),
    ).frosted(
      blur: 5,
      frostColor: UIColorsToken.black,
      borderRadius: borderRadius,
    );
  }

  static String _formatAvgNetWorth(num value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return 'Avg Voter NW: €${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return 'Avg Voter NW: €${k.toStringAsFixed(1)}K';
    }
    return 'Avg Voter NW: €${value.toStringAsFixed(0)}';
  }
}

