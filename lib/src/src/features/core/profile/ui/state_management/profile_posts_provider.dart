import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/utils/enums/report_category_enum.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';
import 'package:brokies/src/src/features/core/profile/data/datasources/profile_posts_remote_datasource.dart';
import 'package:brokies/src/src/features/core/social/data/datasources/social_feed_remote_datasource.dart';
import 'package:brokies/src/src/features/core/social/data/models/feed_post_model.dart';

import 'profile_posts_state.dart';

/// Keyed by userId so each profile wall has its own isolated state.
final profilePostsProvider = StateNotifierProvider.family<
    ProfilePostsNotifier, ProfilePostsState, String>(
  (ref, userId) => ProfilePostsNotifier(
    userId: userId,
    datasource: ref.read(profilePostsRemoteDatasourceProvider),
    socialDatasource: ref.read(socialFeedRemoteDatasourceProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class ProfilePostsNotifier extends StateNotifier<ProfilePostsState> {
  ProfilePostsNotifier({
    required this.userId,
    required this.datasource,
    required this.socialDatasource,
    required this.appEvents,
    required this.locale,
  }) : super(const ProfilePostsState());

  static const _pageSize = 20;

  final String userId;
  final ProfilePostsRemoteDatasource datasource;
  final SocialFeedRemoteDatasource socialDatasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> loadPosts({bool refresh = false}) async {
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
      final page = await datasource.fetchUserPosts(
        userId: userId,
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
        ShowErrorEvent(failure, defaultMessage: failure.toMessage(locale)),
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
      await socialDatasource.setPostLiked(
        postId: postId,
        liked: nextLiked,
      );
    } on ServerException catch (e) {
      list[i] = post;
      state = state.copyWith(posts: list);
      final failure = ServerFailure(exception: e);
      appEvents.send(
        ShowErrorEvent(failure, defaultMessage: failure.toMessage(locale)),
      );
    } catch (e) {
      list[i] = post;
      state = state.copyWith(posts: list);
      appEvents.send(ShowErrorEvent(null, defaultMessage: e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    final res = await Failure.exceptionsCatcher(
      () => socialDatasource.deletePost(postId),
    );
    res.when(
      (_) {
        removePostFromWall(postId);
        appEvents.send(
          ShowSuccessMessageEvent(locale.socialSnackbarPostDeleted),
        );
      },
      (err) {
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }

  Future<void> reportPost(
    String postId,
    ReportCategoryEnum category,
  ) async {
    final res = await Failure.exceptionsCatcher(
      () => socialDatasource.reportPost(postId: postId, category: category),
    );
    res.when(
      (_) {
        appEvents.send(
          ShowSuccessMessageEvent(locale.socialSnackbarReportSubmitted),
        );
      },
      (err) {
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }

  void bumpCommentsCountForPost(String postId) {
    final i = state.posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    final post = state.posts[i];
    final next = (post.commentsCount + 1).clamp(0, 1 << 30) as int;
    final list = List<FeedPostModel>.from(state.posts);
    list[i] = post.copyWith(commentsCount: next);
    state = state.copyWith(posts: list);
  }

  void removePostFromWall(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  Future<bool> createCommentFromWall({
    required String postId,
    required String content,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return false;

    final res = await Failure.exceptionsCatcher(
      () => socialDatasource.createComment(postId: postId, content: text),
    );

    return res.when(
      (_) {
        bumpCommentsCountForPost(postId);
        return true;
      },
      (err) {
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
        return false;
      },
    );
  }
}
