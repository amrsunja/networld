import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/previous_pulses_provider.dart';
import 'package:networld/src/src/features/core/daily/ui/widgets/pulse_poll_card_view.dart';
import 'package:networld/src/src/features/settings/ui/state_management/settings_provider.dart';

/// Past [admin_polls] with read-only results (same card style as today’s pulse).
class PreviousPulsesSection extends ConsumerWidget {
  const PreviousPulsesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(settingsProvider).data?.locale ?? const Locale('en');
    final async = ref.watch(previousPulsesProvider);

    return async.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dailyPreviousPulses,
                style: theme.typo.displayXs.bold.copyWith(
                  color: UIColorsToken.white,
                ),
              ),
              const SizedBox(height: 16),
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: PulsePollCardView(
                    poll: e.poll,
                    results: e.results,
                    locale: locale,
                    titleAboveCard: null,
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: const Color(0xffFFD700).withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
