import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';
import 'package:networld/src/src/core/design_system/src/tokens/colors/ui_colors_token.dart';
import 'package:networld/src/src/core/locale/gen/app_localizations.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/routing/app_router.gr.dart';
import 'package:networld/src/src/core/utils/constants/constants.dart';
import 'package:networld/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/widgets/user_stats_app_bar.dart';
import 'package:networld/src/src/features/core/post/ui/pages/post_comments_page.dart';
import 'package:networld/src/src/features/core/notifications/ui/state_management/notifications_provider.dart';
import 'package:networld/src/src/features/core/profile/ui/state_management/profile_provider.dart';
import 'package:networld/src/src/features/core/social/ui/state_management/social_feed_provider.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:networld/src/src/features/core/social/ui/state_management/social_feed_state.dart';
import 'package:networld/src/src/features/core/social/ui/widgets/feed_post_actions_bottom_sheet.dart';
import 'package:networld/src/src/features/core/social/ui/widgets/feed_post_card.dart';

@RoutePage()
class SocialPage extends HookConsumerWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomLift = MediaQuery.paddingOf(context).bottom + 72;
    final feedState = ref.watch(socialFeedProvider);
    final scrollController = useScrollController();
    final profile = ref.watch(profileProvider).profile;
    final hasUnread = ref.watch(notificationsProvider).hasUnread;

    final netWorth = profile?.netWorth ?? 0;
    final currency = profile?.currency ?? CurrencyType.usd;
    final rankTier = profile?.rankTier ?? RankTierEnum.Starter;
    final rankLabel = RankTierEnum.localizedRankTier(rankTier, l10n);
    final credits = profile?.credits ?? 0;

    useEffect(() {
      Future.microtask(
        () => ref.read(socialFeedProvider.notifier).loadFeed(refresh: true),
      );
      return null;
    }, []);

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final pos = scrollController.position;
        if (pos.maxScrollExtent - pos.pixels < 480) {
          ref.read(socialFeedProvider.notifier).loadFeed(refresh: false);
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

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
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: bottomLift),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: UIColorsToken.pri500.withValues(alpha: 0.8),
                  blurRadius: 30,
                ),
              ],
            ),
            child: FloatingActionButton(
              elevation: 0,
              highlightElevation: 4,
              onPressed: () => context.router.push(const CreatePostRoute()),
              tooltip: l10n.socialCreatePost,
              backgroundColor: UIColorsToken.pri400,
              foregroundColor: UIColorsToken.black,
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: UIColorsToken.pri350,
                  backgroundColor: theme.colors.bgColor,
                  onRefresh: () =>
                      ref.read(socialFeedProvider.notifier).loadFeed(refresh: true),
                  child: _FeedBody(
                    theme: theme,
                    scrollController: scrollController,
                    feedState: feedState,
                    onRetry: () =>
                        ref.read(socialFeedProvider.notifier).loadFeed(refresh: true),
                    onLike: ref.read(socialFeedProvider.notifier).toggleLike,
                    onOpenComments: (postId) => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: theme.colors.bgColor,
                      builder: (_) => FractionallySizedBox(
                        heightFactor: 0.9,
                        child: PostCommentsPage(postId: postId),
                      ),
                    ),
                    onPostMenu: (post) => showFeedPostActionsBottomSheet(
                      context: context,
                      ref: ref,
                      post: post,
                    ),
                    onAuthorTap: (authorId) {
                      final currentUid = supabase.auth.currentUser?.id;
                      if (authorId == currentUid) {
                        context.router.navigate(const ProfileRouterRoute());
                      } else {
                        context.router.push(
                          UserProfileRoute(userId: authorId),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedBody extends StatelessWidget {
  const _FeedBody({
    required this.theme,
    required this.scrollController,
    required this.feedState,
    required this.onRetry,
    required this.onLike,
    required this.onOpenComments,
    required this.onPostMenu,
    this.onAuthorTap,
  });

  final UIThemeData theme;
  final ScrollController scrollController;
  final SocialFeedState feedState;
  final VoidCallback onRetry;
  final void Function(String postId) onLike;
  final void Function(String postId) onOpenComments;
  final void Function(FeedPostModel post) onPostMenu;
  final void Function(String authorId)? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (feedState.isRefreshing && feedState.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: UICircularProgressBar()),
        ],
      );
    }

    if (feedState.errorMessage != null && feedState.posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
          Text(
            feedState.errorMessage!,
            textAlign: TextAlign.center,
            style: theme.typo.textSm.regular.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: UIButton.primary(
              title: l10n.socialFeedRetry,
              onTap: onRetry,
            ),
          ),
        ],
      );
    }

    if (feedState.posts.isEmpty && !feedState.isRefreshing) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: kPageHorzPadding),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
          Text(
            l10n.socialFeedEmpty,
            textAlign: TextAlign.center,
            style: theme.typo.textMd.medium.copyWith(
              color: theme.colors.secondContentColor,
            ),
          ),
        ],
      );
    }

    final itemCount = feedState.posts.length +
        (feedState.hasMore && feedState.isLoadingMore ? 1 : 0);

    return ListView.separated(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        kPageHorzPadding,
        30,
        kPageHorzPadding,
        100,
      ),
      itemCount: itemCount,
      separatorBuilder: (context, ind) => UISpace.vert(10),
      itemBuilder: (context, index) {
        if (index >= feedState.posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: UICircularProgressBar()),
          );
        }
        final post = feedState.posts[index];
        return FeedPostCard(
          post: post,
          onLikeTap: () => onLike(post.id),
          onCommentTap: () => onOpenComments(post.id),
          onMoreTap: () => onPostMenu(post),
          onAuthorTap: onAuthorTap != null
              ? () => onAuthorTap!(post.authorId)
              : null,
        );
      },
    );
  }
}
