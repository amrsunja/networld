import 'package:networld/src/src/features/core/profile/data/models/follow_user_model.dart';

class FollowListState {
  const FollowListState({
    this.users = const [],
    this.cursor,
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<FollowUserModel> users;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  FollowListState copyWith({
    List<FollowUserModel>? users,
    String? cursor,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return FollowListState(
      users: users ?? this.users,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
