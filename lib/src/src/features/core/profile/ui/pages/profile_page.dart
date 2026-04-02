import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/core/widgets/pagination/infinity_data_scroll.dart';
import 'package:networld/src/src/features/core/post/ui/pages/post_comments_page.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_posts_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_posts_state.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:networld/src/src/features/core/social/ui/widgets/feed_post_card.dart';

import 'profile_followers_page.dart';
import 'profile_followings_page.dart';

const Color _kMutedLabel = Color(0xFF808080);

const Duration _kProfileAnimDuration = Duration(milliseconds: 720);
const int _kProfileStaggerMs = 190;
const double _kProfileSlideBegin = 32;

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
    final profileNotifier = ref.read(profileProvider.notifier);
    final profileState = ref.watch(profileProvider);
    final scrollController = useScrollController();

    final userId = profileState.profile?.id;

    final postsState = userId != null
        ? ref.watch(profilePostsProvider(userId))
        : const ProfilePostsState();

    useEffect(() {
      Future.microtask(() async {
        await profileNotifier.loadProfile();
      });
      return null;
    }, []);

    useEffect(() {
      if (userId == null) return null;
      Future.microtask(
        () => ref.read(profilePostsProvider(userId).notifier).loadPosts(
              refresh: true,
            ),
      );
      return null;
    }, [userId]);

    Future<void> onRefresh() async {
      await profileNotifier.loadProfile();
      if (userId != null) {
        await ref
            .read(profilePostsProvider(userId).notifier)
            .loadPosts(refresh: true);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: profileState.isLoading && profileState.profile == null
            ? const Center(child: UICircularProgressBar())
            : RefreshIndicator(
                color: UIColorsToken.pri350,
                backgroundColor: theme.colors.bgColor,
                onRefresh: onRefresh,
                child: InfinityDataScrollWidget(
                  scrollController: scrollController,
                  onScrollEnd: () {
                    if (userId == null) return;
                    final ps = ref.read(profilePostsProvider(userId));
                    if (!ps.isLoadingMore && ps.hasMore) {
                      ref
                          .read(profilePostsProvider(userId).notifier)
                          .loadPosts();
                    }
                  },
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kPageHorzPadding,
                        ),
                        sliver: SliverToBoxAdapter(
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
                                        color: theme.colors.contentColor
                                            .withValues(alpha: 0.85),
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
                                      style:
                                          theme.typo.textSm.regular.copyWith(
                                        color: UIColorsToken.neg500,
                                      ),
                                    ),
                                  ),
                                  1,
                                ),
                              if (profileState.profile != null)
                                _ProfileHeader(
                                  profile: profileState.profile!,
                                  postsCount: postsState.posts.length,
                                )
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
                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                      if (userId != null)
                        _ProfilePostsSliver(
                          userId: userId,
                          postsState: postsState,
                          theme: theme,
                          ref: ref,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ProfilePostsSliver extends StatelessWidget {
  const _ProfilePostsSliver({
    required this.userId,
    required this.postsState,
    required this.theme,
    required this.ref,
  });

  final String userId;
  final ProfilePostsState postsState;
  final UIThemeData theme;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (postsState.isRefreshing && postsState.posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(child: UICircularProgressBar()),
        ),
      );
    }

    if (postsState.errorMessage != null && postsState.posts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                postsState.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.typo.textSm.regular.copyWith(
                  color: theme.colors.secondContentColor,
                ),
              ),
              const SizedBox(height: 16),
              UIButton.primary(
                title: l10n.socialFeedRetry,
                onTap: () => ref
                    .read(profilePostsProvider(userId).notifier)
                    .loadPosts(refresh: true),
              ),
            ],
          ),
        ),
      );
    }

    if (postsState.posts.isEmpty && !postsState.isRefreshing) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kPageHorzPadding,
            vertical: 40,
          ),
          child: Text(
            l10n.profilePostsEmpty,
            textAlign: TextAlign.center,
            style: theme.typo.textMd.medium.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
        ),
      );
    }

    final itemCount = postsState.posts.length +
        (postsState.hasMore && postsState.isLoadingMore ? 1 : 0);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        kPageHorzPadding,
        0,
        kPageHorzPadding,
        100,
      ),
      sliver: SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= postsState.posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: UICircularProgressBar()),
            );
          }
          final post = postsState.posts[index];
          return FeedPostCard(
            post: post,
            onLikeTap: () => ref
                .read(profilePostsProvider(userId).notifier)
                .toggleLike(post.id),
            onQuickCommentSend: (text) => ref
                .read(profilePostsProvider(userId).notifier)
                .createCommentFromWall(postId: post.id, content: text),
            onCommentTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: theme.colors.bgColor,
              builder: (_) => FractionallySizedBox(
                heightFactor: 0.7,
                child: PostCommentsPage(postId: post.id),
              ),
            ),
            onMoreTap: () => _showProfilePostActionsBottomSheet(
              context: context,
              ref: ref,
              post: post,
              userId: userId,
            ),
          );
        },
      ),
    );
  }
}

// ─── Profile post actions bottom sheet ──────────────────────────────

void _showProfilePostActionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required FeedPostModel post,
  required String userId,
}) {
  final theme = AppTheme.of(context);
  final l10n = AppLocalizations.of(context);
  final uid = supabase.auth.currentUser?.id;
  final isOwn = uid != null && post.authorId == uid;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).padding.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.fgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _SheetActionRow(
                    icon: Icons.flag_outlined,
                    label: l10n.socialActionReport,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Future.microtask(
                        () => _showProfilePostReportSheet(
                          context,
                          ref,
                          l10n,
                          post.id,
                          userId,
                        ),
                      );
                    },
                  ),
                  if (isOwn) ...[
                    Divider(
                      height: 1,
                      color: theme.colors.secondContentColor
                          .withValues(alpha: 0.2),
                    ),
                    _SheetActionRow(
                      icon: Icons.delete_outline_rounded,
                      label: l10n.socialActionDelete,
                      foregroundColor: UIColorsToken.neg500,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Future.microtask(
                          () => _confirmAndDeleteProfilePost(
                            context,
                            ref,
                            l10n,
                            post.id,
                            userId,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _confirmAndDeleteProfilePost(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  String postId,
  String userId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogCtx) {
      final t = AppTheme.of(dialogCtx);
      return AlertDialog(
        backgroundColor: t.colors.fgColor,
        title: Text(
          l10n.socialDeletePostTitle,
          style: t.typo.textLg.bold.copyWith(color: t.colors.contentColor),
        ),
        content: Text(
          l10n.socialDeleteCannotUndoBody,
          style: t.typo.textSm.regular
              .copyWith(color: t.colors.secondContentColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              l10n.deleteAccountCancel,
              style: TextStyle(color: t.colors.secondContentColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n.socialActionDelete,
              style: const TextStyle(color: UIColorsToken.neg500),
            ),
          ),
        ],
      );
    },
  );
  if (confirmed == true && context.mounted) {
    await ref.read(profilePostsProvider(userId).notifier).deletePost(postId);
  }
}

void _showProfilePostReportSheet(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  String postId,
  String userId,
) {
  final theme = AppTheme.of(context);
  final categories = ReportCategoryEnum.values;
  final notifier = ref.read(profilePostsProvider(userId).notifier);

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).padding.bottom + 12,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.fgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < categories.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: theme.colors.secondContentColor
                        .withValues(alpha: 0.2),
                  ),
                _SheetActionRow(
                  icon: Icons.report_outlined,
                  label: _reportCategoryLabel(categories[i], l10n),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    notifier.reportPost(postId, categories[i]);
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _reportCategoryLabel(ReportCategoryEnum c, AppLocalizations l10n) {
  return switch (c) {
    ReportCategoryEnum.spam => l10n.socialReportCategorySpam,
    ReportCategoryEnum.harassment => l10n.socialReportCategoryHarassment,
    ReportCategoryEnum.inappropriate => l10n.socialReportCategoryInappropriate,
    ReportCategoryEnum.other => l10n.socialReportCategoryOther,
  };
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = foregroundColor ?? theme.colors.contentColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.typo.textMd.medium.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header ──────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.postsCount,
  });

  final ProfileModel profile;
  final int postsCount;

  static const double _avatarSize = 112;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final gold = UIColorsToken.pri350;
    final userId = profile.id;

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
            GestureDetector(
              onTap: () => context.router.push(
                const ProfileAvatarsRoute(),
              ),
              child: UIAvatar(
                avatarId: profile.avatarId,
                size: _avatarSize,
                username: profile.username,
                borderWidth: 3,
                borderColor: UIColorsToken.sec400,
                isVerified: profile.isVerified,
                glowColor: UIColorsToken.pri350.withValues(alpha: 0.6),
                glowRadius: 12,
              ),
            ),
            0,
          ),
          const SizedBox(height: 20),
          _profileEnter(
            Text(
              profile.username,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                Flexible(
                  child: Text(
                    profile.isVerified
                        ? l10n.profileVerifiedNetWorthLabel
                        : l10n.profileNetWorthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: _kMutedLabel,
                    ),
                  ),
                ),
                if (profile.isVerified) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.lock_rounded, size: 14, color: gold),
                ],
                const SizedBox(width: 8),
                UIRankBadge(
                  label: _localizedRankTier(profile.rankTier, l10n),
                  rankTier: profile.rankTier,
                  compact: true,
                ),
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
              followersValue: profile.followersCount,
              followingValue: profile.followingCount,
              postsValue: postsCount,
              theme: theme,
              onFollowersTap: () => _openFollowersSheet(context, userId),
              onFollowingTap: () => _openFollowingsSheet(context, userId),
            ),
            4,
          ),
        ],
      ),
    );
  }
}

void _openFollowersSheet(BuildContext context, String userId) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.7,
      child: ProfileFollowersPage(userId: userId),
    ),
  );
}

void _openFollowingsSheet(BuildContext context, String userId) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.7,
      child: ProfileFollowingsPage(userId: userId),
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.l10n,
    required this.rankTier,
    required this.followersValue,
    required this.followingValue,
    required this.postsValue,
    required this.theme,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  final AppLocalizations l10n;
  final RankTierEnum rankTier;
  final int followersValue;
  final int followingValue;
  final int postsValue;
  final UIThemeData theme;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  @override
  Widget build(BuildContext context) {
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
    final divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: UIColorsToken.neu400.withValues(alpha: 0.45),
    );

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFollowersTap,
              child: _StatCell(
                value: '$followersValue',
                label: l10n.profileStatFollowers,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
            ),
          ),
          divider,
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFollowingTap,
              child: _StatCell(
                value: '$followingValue',
                label: l10n.profileStatFollowing,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
            ),
          ),
          divider,
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
        Text(
          value,
          style: valueStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: labelStyle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
