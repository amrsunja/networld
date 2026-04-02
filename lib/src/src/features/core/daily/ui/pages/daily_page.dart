import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/widgets/user_stats_app_bar.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_provider.dart';
import 'package:networld/src/src/features/core/notifications/ui/state_management/notifications_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/daily_missions_section.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/daily_poll_card.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/previous_pulses_section.dart';

const Duration _kDailyAnimDuration = Duration(milliseconds: 720);
const int _kDailyStaggerMs = 190;
const double _kDailySlideBegin = 32;

Widget _dailyEnter(Widget child, int step) {
  final delayMs = step * _kDailyStaggerMs;
  final delay = Duration(milliseconds: delayMs);
  return child
      .animate()
      .fade(
        delay: delay,
        duration: _kDailyAnimDuration,
        curve: Curves.easeOutCubic,
      )
      .moveY(
        delay: delay,
        duration: _kDailyAnimDuration,
        begin: _kDailySlideBegin,
        curve: Curves.easeOutCubic,
      );
}

@RoutePage()
class DailyPage extends HookConsumerWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final dailyNotifier = ref.read(dailyProvider.notifier);
    final dailyState = ref.watch(dailyProvider);
    final profile = ref.watch(profileProvider).profile;
    final hasUnread = ref.watch(notificationsProvider).hasUnread;

    useEffect(() {
      Future.microtask(() async {
        await Future.wait<void>([
          dailyNotifier.loadPoll(),
          dailyNotifier.loadMissions(),
        ]);
      });
      return null;
    }, []);

    final hasErrorBanner = dailyState.errorMessage != null;

    final netWorth = profile?.netWorth ?? 0;
    final currency = profile?.currency ?? CurrencyType.usd;
    final rankTier = profile?.rankTier ?? RankTierEnum.Starter;
    final rankLabel = _localizedRankTier(rankTier, l10n);
    final credits = profile?.credits ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: .topCenter,
        end: .bottomCenter,
          colors: [
            Color(0xff131209),
            UIColorsToken.black,
          ]
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: UserStatsAppBar(
          netWorth: netWorth,
          currency: currency,
          rankLabel: rankLabel,
          rankTier: rankTier,
          rankPrefixLabel: l10n.dailyAppBarRankPrefix,
          credits: credits,
          avatarId: profile?.avatarId ?? 1,
          username: profile?.username,
          isVerified: profile?.isVerified ?? false,
          hasUnreadNotifications: hasUnread,
          onNotificationTap: () => context.router.push(const NotificationsRoute()),
          notificationTooltip: l10n.dailyAppBarNotificationsTooltip,
        ),
        body: dailyState.isLoading && dailyState.poll == null
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                kPageHorzPadding,
                20,
                kPageHorzPadding,
                80
              ),
              child: Column(
                children: [
                  if (hasErrorBanner)
                    _dailyEnter(
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kPageHorzPadding,
                          vertical: 8,
                        ),
                        child: Text(
                          dailyState.errorMessage!,
                          style: theme.typo.textMd.regular.copyWith(
                            color: UIColorsToken.neg500,
                          ),
                        ),
                      ),
                      0,
                    ),
                  _dailyEnter(
                    const DailyPollCard(),
                    hasErrorBanner ? 1 : 0,
                  ),
                  _dailyEnter(
                    const DailyMissionsSection(),
                    hasErrorBanner ? 2 : 1,
                  ),
                  _dailyEnter(
                    const PreviousPulsesSection(),
                    hasErrorBanner ? 3 : 2,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

String _localizedRankTier(RankTierEnum tier, AppLocalizations l10n) {
  switch (tier) {
    case RankTierEnum.Starter:
      return l10n.rankTierStarter;
    case RankTierEnum.Builder:
      return l10n.rankTierBuilder;
    case RankTierEnum.Scaler:
      return l10n.rankTierScaler;
    case RankTierEnum.Elite:
      return l10n.rankTierElite;
    case RankTierEnum.Whale:
      return l10n.rankTierWhale;
  }
}
