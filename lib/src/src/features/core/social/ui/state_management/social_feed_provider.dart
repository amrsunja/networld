import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/social/data/datasources/social_feed_remote_datasource.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';

import 'social_feed_state.dart';

final socialFeedProvider =
    StateNotifierProvider<SocialFeedNotifier, SocialFeedState>(
  (ref) => SocialFeedNotifier(
    datasource: ref.read(socialFeedRemoteDatasourceProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class SocialFeedNotifier extends StateNotifier<SocialFeedState> {
  SocialFeedNotifier({
    required this.datasource,
    required this.appEvents,
    required this.locale,
  }) : super(const SocialFeedState());

  static const _pageSize = 20;

  final SocialFeedRemoteDatasource datasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> loadFeed({bool refresh = false}) async {
    if (!refresh) {
      if (!state.hasMore) return;
      if (state.isLoadingMore) return;
      if (state.posts.isEmpty) return;
    }
    if (state.isRefreshing) return;

    final cursorToUse = refresh ? null : state.cursor;

    if (refresh) {
      state = state.copyWith(
        isRefreshing: true,
        clearError: true,
        cursor: null,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      final page = await datasource.fetchFeedPage(
        limit: _pageSize,
        cursor: cursorToUse,
      );
      final posts = refresh
          ? page.posts
          : <FeedPostModel>[...state.posts, ...page.posts];
      state = state.copyWith(
        posts: posts,
        cursor: page.nextCursor,
        hasMore: page.hasMore,
        isRefreshing: false,
        isLoadingMore: false,
      );
    } on ServerException catch (e) {
      final failure = ServerFailure(exception: e);
      state = state.copyWith(
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: failure.toMessage(locale),
      );
      appEvents.send(
        ShowErrorEvent(
          failure,
          defaultMessage: failure.toMessage(locale),
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
      appEvents.send(
        ShowErrorEvent(null, defaultMessage: e.toString()),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    final i = state.posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    final post = state.posts[i];
    final nextLiked = !post.isLiked;
    final delta = nextLiked ? 1 : -1;
    final nextCount = (post.likesCount + delta).clamp(0, 1 << 30) as int;

    final optimistic = post.copyWith(
      isLiked: nextLiked,
      likesCount: nextCount,
    );
    final list = List<FeedPostModel>.from(state.posts);
    list[i] = optimistic;
    state = state.copyWith(posts: list);

    try {
      await datasource.setPostLiked(postId: postId, liked: nextLiked);
    } on ServerException catch (e) {
      list[i] = post;
      state = state.copyWith(posts: list);
      final failure = ServerFailure(exception: e);
      appEvents.send(
        ShowErrorEvent(
          failure,
          defaultMessage: failure.toMessage(locale),
        ),
      );
    } catch (e) {
      list[i] = post;
      state = state.copyWith(posts: list);
      appEvents.send(ShowErrorEvent(null, defaultMessage: e.toString()));
    }
  }
}
