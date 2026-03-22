import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/features/core/daily/data/models/mission_model.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_provider.dart';
import 'package:networld/src/src/features/core/daily/ui/state_management/daily_state.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyMissionsSection extends ConsumerStatefulWidget {
  const DailyMissionsSection({super.key});

  @override
  ConsumerState<DailyMissionsSection> createState() => _DailyMissionsSectionState();
}

/// One mission at a time: cooldown / claim / awaiting browser blocks others.
bool _missionActionEnabled(DailyState state, MissionModel m) {
  if (state.claimedMissionRefIds.contains(m.id)) return false;
  if (state.cooldownMissionId == m.id || state.claimingMissionId == m.id) {
    return false;
  }
  if (state.claimingMissionId != null) return false;
  if (state.cooldownMissionId != null) return false;
  if (state.awaitingResumeMissionId != null) return false;
  return true;
}

class _DailyMissionsSectionState extends ConsumerState<DailyMissionsSection>
    with WidgetsBindingObserver {
  static const _gold = Color(0xFFFFD700);

  static Uri? _uriFromLink(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final t = raw.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return Uri.tryParse(t);
    }
    return Uri.tryParse('https://$t');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(dailyProvider.notifier).onAppResumedAfterMissionLink();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(dailyProvider);
    final notifier = ref.read(dailyProvider.notifier);

    if (state.isLoadingMissions && state.missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: UICircularProgressBar()),
      );
    }

    if (state.missions.isEmpty && state.missionsErrorMessage == null) {
      return const SizedBox.shrink();
    }

    final completed = state.missions
        .where((m) => state.claimedMissionRefIds.contains(m.id))
        .length;
    final total = state.missions.length;

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dailyMissions,
                  style: theme.typo.displayXs.bold.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
              ),
              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    '$completed/$total',
                    style: theme.typo.textSm.semibold.copyWith(
                      color: _gold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          if (state.missionsErrorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              state.missionsErrorMessage!,
              style: theme.typo.textMd.regular.copyWith(
                color: UIColorsToken.neg500,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...state.missions.map((m) {
            final claimed = state.claimedMissionRefIds.contains(m.id);
            final loading =
                state.cooldownMissionId == m.id || state.claimingMissionId == m.id;
            final awaitingBrowser = state.awaitingResumeMissionId == m.id;
            final actionEnabled = _missionActionEnabled(state, m);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MissionRow(
                mission: m,
                uri: _uriFromLink(m.link),
                l10n: l10n,
                theme: theme,
                claimed: claimed,
                loading: loading,
                awaitingBrowser: awaitingBrowser,
                lockedByOther: !claimed &&
                    !loading &&
                    !awaitingBrowser &&
                    !actionEnabled,
                canAct: actionEnabled,
                onOpenLink: () async {
                  final uri = _uriFromLink(m.link);
                  if (uri == null) return;
                  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (ok && context.mounted) {
                    notifier.onMissionLinkLaunched(m.id);
                  }
                },
                onStartLinkless: () => notifier.startCooldownForLinklessMission(m.id),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.mission,
    required this.uri,
    required this.l10n,
    required this.theme,
    required this.claimed,
    required this.loading,
    required this.awaitingBrowser,
    required this.lockedByOther,
    required this.canAct,
    required this.onOpenLink,
    required this.onStartLinkless,
  });

  final MissionModel mission;
  final Uri? uri;
  final AppLocalizations l10n;
  final UIThemeData theme;
  final bool claimed;
  final bool loading;
  final bool awaitingBrowser;
  final bool lockedByOther;
  final bool canAct;
  final VoidCallback onOpenLink;
  final VoidCallback onStartLinkless;

  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final dimmed = claimed || lockedByOther;
    final border = _gold.withValues(alpha: claimed ? 0.12 : 0.35);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
          color: theme.colors.cardColor.withValues(alpha: 0.45),
          boxShadow: claimed
              ? null
              : [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LeadingIcon(
              claimed: claimed,
              loading: loading,
              awaitingBrowser: awaitingBrowser,
              lockedByOther: lockedByOther,
              hasLink: uri != null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: theme.typo.textLg.semibold.copyWith(
                      color: theme.colors.contentColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${mission.rewardCredits} credits',
                    style: theme.typo.textSm.regular.copyWith(
                      color: dimmed
                          ? theme.colors.contentColor.withValues(alpha: 0.45)
                          : theme.colors.contentColor.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _TrailingAction(
              claimed: claimed,
              loading: loading,
              hasLink: uri != null,
              canAct: canAct,
              l10n: l10n,
              onOpenLink: onOpenLink,
              onStartLinkless: onStartLinkless,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.claimed,
    required this.loading,
    required this.awaitingBrowser,
    required this.lockedByOther,
    required this.hasLink,
  });

  final bool claimed;
  final bool loading;
  final bool awaitingBrowser;
  final bool lockedByOther;
  final bool hasLink;

  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (loading) {
      child = const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: _gold,
        ),
      );
    } else if (claimed) {
      child = Icon(
        Icons.check_rounded,
        color: _gold,
        size: 22,
      );
    } else if (awaitingBrowser) {
      child = Icon(
        Icons.hourglass_top_rounded,
        color: _gold.withValues(alpha: 0.85),
        size: 22,
      );
    } else if (lockedByOther) {
      child = Icon(
        Icons.lock_outline_rounded,
        color: UIColorsToken.white.withValues(alpha: 0.35),
        size: 20,
      );
    } else {
      child = Icon(
        hasLink ? Icons.open_in_new_rounded : Icons.touch_app_rounded,
        color: _gold,
        size: 22,
      );
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: claimed || loading
            ? _gold.withValues(alpha: 0.12)
            : UIColorsToken.black.withValues(alpha: 0.35),
        border: Border.all(
          color: _gold.withValues(alpha: claimed || loading ? 0.35 : 0.2),
        ),
      ),
      child: child,
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({
    required this.claimed,
    required this.loading,
    required this.hasLink,
    required this.canAct,
    required this.l10n,
    required this.onOpenLink,
    required this.onStartLinkless,
  });

  final bool claimed;
  final bool loading;
  final bool hasLink;
  final bool canAct;
  final AppLocalizations l10n;
  final VoidCallback onOpenLink;
  final VoidCallback onStartLinkless;

  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (claimed) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          l10n.dailyClaimed,
          style: theme.typo.textSm.semibold.copyWith(
            color: _gold.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      );
    }

    if (loading) {
      return const SizedBox(width: 40, height: 40);
    }

    if (hasLink) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canAct ? onOpenLink : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: canAct ? _gold : _gold.withValues(alpha: 0.35),
              boxShadow: canAct
                  ? [
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              l10n.dailyOpenLink,
              style: theme.typo.textSm.bold.copyWith(
                color: UIColorsToken.black,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canAct ? onStartLinkless : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: canAct ? _gold : _gold.withValues(alpha: 0.35),
            boxShadow: canAct
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            l10n.dailyMissionStart,
            style: theme.typo.textSm.bold.copyWith(
              color: UIColorsToken.black,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
