import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';

enum SocialFeedFilter {
  recents,
  hots,
  followings;

  String get apiValue => name;
}

class SocialFeedState {
  const SocialFeedState({
    this.filter = SocialFeedFilter.recents,
    this.posts = const [],
    this.cursor,
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final SocialFeedFilter filter;
  final List<FeedPostModel> posts;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  static const Object _cursorUnset = Object();

  SocialFeedState copyWith({
    SocialFeedFilter? filter,
    List<FeedPostModel>? posts,
    Object? cursor = _cursorUnset,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SocialFeedState(
      filter: filter ?? this.filter,
      posts: posts ?? this.posts,
      cursor: identical(cursor, _cursorUnset) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
