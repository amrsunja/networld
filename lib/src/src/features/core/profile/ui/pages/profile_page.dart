import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';

const Color _kMutedLabel = Color(0xFF808080);

const Duration _kProfileAnimDuration = Duration(milliseconds: 720);
const int _kProfileStaggerMs = 190;
const double _kProfileSlideBegin = 32;

/// Staggered fade + upward move for profile sections (delay grows with [step]).
Widget _profileEnter(Widget child, int step) {
  final delayMs = step * _kProfileStaggerMs;
  final delay = Duration(milliseconds: delayMs);
  return child
      .animate()
      .fade(
        delay: delay,
        duration: _kProfileAnimDuration,
        curve: Curves.easeOutCubic,
      )
      .moveY(
        delay: delay,
        duration: _kProfileAnimDuration,
        begin: _kProfileSlideBegin,
        curve: Curves.easeOutCubic,
      );
}

@RoutePage()
class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final provider = ref.read(profileProvider.notifier);
    final profileState = ref.watch(profileProvider);

    useEffect(() {
      Future.microtask(() async {
        await provider.loadProfile();
      });
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: profileState.isLoading && profileState.profile == null
            ? const Center(child: UICircularProgressBar())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: kPageHorzPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileEnter(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: l10n.settingsTooltip,
                            icon: Icon(
                              Icons.settings_outlined,
                              color: theme.colors.contentColor.withValues(
                                alpha: 0.85,
                              ),
                            ),
                            onPressed: () => context.router.push(
                              const SettingsRoute(),
                            ),
                          ),
                        ],
                      ),
                      0,
                    ),
                    if (profileState.errorMessage != null)
                      _profileEnter(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            profileState.errorMessage!,
                            style: theme.typo.textSm.regular.copyWith(
                              color: UIColorsToken.neg500,
                            ),
                          ),
                        ),
                        1,
                      ),
                    if (profileState.profile != null)
                      _ProfileHeader(profile: profileState.profile!)
                    else if (!profileState.isLoading)
                      _profileEnter(
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Text(
                            l10n.profileUnavailable,
                            textAlign: TextAlign.center,
                            style: theme.typo.textMd.regular,
                          ),
                        ),
                        1,
                      ),
                    // Reserved for tabs, feed, settings, etc.
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: double.infinity,
                      height: 200,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ProfileModel profile;

  static const double _avatarSize = 112;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 70,
            color: UIColorsToken.pri550.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profileEnter(
            _AvatarBlock(
              username: profile.username,
              isVerified: profile.isVerified,
              gold: gold,
            ),
            0,
          ),
          const SizedBox(height: 20),
          _profileEnter(
            Text(
              profile.username,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: theme.colors.contentColor,
                height: 1.15,
              ),
            ),
            1,
          ),
          const SizedBox(height: 10),
          _profileEnter(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.isVerified
                      ? l10n.profileVerifiedNetWorthLabel
                      : l10n.profileNetWorthLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    color: _kMutedLabel,
                  ),
                ),
                if (profile.isVerified) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.lock_rounded, size: 14, color: gold),
                ],
              ],
            ),
            2,
          ),
          const SizedBox(height: 16),
          _profileEnter(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: UIColorsToken.pri350.withValues(alpha: 0.2),
                ),
                color: const Color(0xff241E12),
              ),
              child: UINetWorthWidget(
                netWorth: profile.netWorth,
                currency: profile.currency,
              ),
            ),
            3,
          ),
          const SizedBox(height: 28),
          _profileEnter(
            _StatsRow(
              l10n: l10n,
              rankTier: profile.rankTier,
              followersValue: 0,
              postsValue: 0,
              theme: theme,
            ),
            4,
          ),
        ],
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({
    required this.username,
    required this.isVerified,
    required this.gold,
  });

  final String username;
  final bool isVerified;
  final Color gold;

  static const double _avatarSize = _ProfileHeader._avatarSize;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromUsername(username);

    return SizedBox(
      width: _avatarSize + 8,
      height: _avatarSize + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: _avatarSize + 8,
            height: _avatarSize + 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: UIColorsToken.pri350.withValues(alpha: 0.6),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: UIColorsToken.sec400, width: 3),
              color: UIColorsToken.black.withValues(alpha: 0.8),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: UIColorsToken.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          if (isVerified)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                  border: Border.all(
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: UIColorsToken.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.l10n,
    required this.rankTier,
    required this.followersValue,
    required this.postsValue,
    required this.theme,
  });

  final AppLocalizations l10n;
  final RankTierEnum rankTier;
  final int followersValue;
  final int postsValue;
  final UIThemeData theme;

  @override
  Widget build(BuildContext context) {
    final rankDisplay = _localizedRankTier(rankTier, l10n);
    final labelStyle = GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.1,
      color: _kMutedLabel,
    );
    final valueStyle = GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: theme.colors.contentColor,
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: rankDisplay.toLowerCase(),
              label: l10n.profileStatRank,
              valueStyle: theme.typo.textMd.medium.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
              labelStyle: labelStyle,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: UIColorsToken.neu400.withValues(alpha: 0.45),
          ),
          Expanded(
            child: _StatCell(
              value: '$followersValue',
              label: l10n.profileStatFollowers,
              valueStyle: valueStyle,
              labelStyle: labelStyle,
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: UIColorsToken.neu400.withValues(alpha: 0.45),
          ),
          Expanded(
            child: _StatCell(
              value: '$postsValue',
              label: l10n.profileStatPosts,
              valueStyle: valueStyle,
              labelStyle: labelStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.valueStyle,
    required this.labelStyle,
  });

  final String value;
  final String label;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: valueStyle),
        const SizedBox(height: 4),
        Text(label, style: labelStyle, textAlign: TextAlign.center),
      ],
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

String _initialsFromUsername(String username) {
  final t = username.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    final a = parts[0].isNotEmpty ? parts[0][0] : '';
    final b = parts[1].isNotEmpty ? parts[1][0] : '';
    return ('$a$b').toUpperCase();
  }
  final s = parts[0];
  return s.length >= 2
      ? s.substring(0, 2).toUpperCase()
      : s.toUpperCase();
}
