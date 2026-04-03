import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/features/core/daily/ui/state_management/daily_provider.dart';
import 'package:brokies/src/src/features/core/daily/ui/widgets/pulse_poll_card_view.dart';
import 'package:brokies/src/src/features/settings/ui/state_management/settings_provider.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';

class DailyPollCard extends ConsumerWidget {
  const DailyPollCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyProvider);
    final notifier = ref.read(dailyProvider.notifier);
    final poll = state.poll;
    final locale = ref.watch(settingsProvider).data?.locale ?? L10n.defaultLocale;
    final l10n = AppLocalizations.of(context);

    if (poll == null) {
      return const SizedBox.shrink();
    }

    return PulsePollCardView(
      poll: poll,
      results: state.results,
      locale: locale,
      titleAboveCard: l10n.dailyTodaysPulse,
      readOnly: false,
      userVotedOptionId: state.userVotedOptionId,
      isVoting: state.isVoting,
      onOptionTap: (id) => notifier.castVote(id),
    );
  }
}
