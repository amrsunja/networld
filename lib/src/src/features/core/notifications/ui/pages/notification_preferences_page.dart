import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';
import 'package:brokies/src/src/core/utils/constants/constants.dart';
import 'package:brokies/src/src/features/core/notifications/ui/state_management/notification_preferences_provider.dart';

@RoutePage()
class NotificationPreferencesPage extends HookConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notificationPreferencesProvider);

    useEffect(() {
      Future.microtask(
        () => ref
            .read(notificationPreferencesProvider.notifier)
            .loadPreferences(),
      );
      return null;
    }, []);

    return Scaffold(
      backgroundColor: theme.colors.bgColor,
      appBar: AppBar(
        backgroundColor: theme.colors.bgColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: theme.colors.contentColor,
        title: Text(
          l10n.notificationPreferencesTitle,
          style: theme.typo.textMd.semibold.copyWith(
            color: theme.colors.contentColor,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: UICircularProgressBar())
          : state.preferences == null
              ? Center(
                  child: Text(
                    l10n.notificationsEmpty,
                    style: theme.typo.textMd.medium.copyWith(
                      color: theme.colors.secondContentColor,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPageHorzPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        l10n.notificationPreferencesDescription,
                        style: theme.typo.textSm.regular.copyWith(
                          color: theme.colors.secondContentColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _PreferenceRow(
                        title: l10n.notificationPrefLikePost,
                        subtitle: l10n.notificationPrefLikePostDesc,
                        value: state.preferences!.likePost,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('like_post', v),
                      ),
                      const SizedBox(height: 8),
                      _PreferenceRow(
                        title: l10n.notificationPrefComment,
                        subtitle: l10n.notificationPrefCommentDesc,
                        value: state.preferences!.comment,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('comment', v),
                      ),
                      const SizedBox(height: 8),
                      _PreferenceRow(
                        title: l10n.notificationPrefNewFollower,
                        subtitle: l10n.notificationPrefNewFollowerDesc,
                        value: state.preferences!.newFollower,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('new_follower', v),
                      ),
                      const SizedBox(height: 8),
                      _PreferenceRow(
                        title: l10n.notificationPrefReward,
                        subtitle: l10n.notificationPrefRewardDesc,
                        value: state.preferences!.reward,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('reward', v),
                      ),
                      const SizedBox(height: 8),
                      _PreferenceRow(
                        title: l10n.notificationPrefRanking,
                        subtitle: l10n.notificationPrefRankingDesc,
                        value: state.preferences!.ranking,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('ranking', v),
                      ),
                      const SizedBox(height: 8),
                      _PreferenceRow(
                        title: l10n.notificationPrefSystem,
                        subtitle: l10n.notificationPrefSystemDesc,
                        value: state.preferences!.system,
                        onChanged: (v) => ref
                            .read(notificationPreferencesProvider.notifier)
                            .togglePreference('system', v),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0F),
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          top: BorderSide(color: Color(0x1FFFFFFF), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typo.textMd.bold.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.typo.textSm.regular,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          UIToggle(
            checked: value,
            onCheck: onChanged,
          ),
        ],
      ),
    );
  }
}
