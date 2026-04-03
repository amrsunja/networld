import 'package:brokies/src/src/features/core/social/data/models/feed_post_model.dart';

class ProfilePostsState {
  const ProfilePostsState({
    this.posts = const [],
    this.cursor,
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<FeedPostModel> posts;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  ProfilePostsState copyWith({
    List<FeedPostModel>? posts,
    String? cursor,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfilePostsState(
      posts: posts ?? this.posts,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
