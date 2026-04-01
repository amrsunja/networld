import 'package:networld/src/src/features/core/post/data/models/post_comment_model.dart';

class PostCommentsReplyTarget {
  const PostCommentsReplyTarget({
    required this.commentId,
    required this.username,
    this.parentCommentId,
  });

  final String commentId;
  final String username;

  /// If the target is a child comment, this is its parent's ID.
  /// Used to always resolve replies to the root parent.
  final String? parentCommentId;
}

class PostCommentsState {
  const PostCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.errorMessage,
    this.replyTarget,
    this.nextCursor,
    this.hasMore = true,
  });

  final List<PostCommentModel> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isSending;
  final String? errorMessage;
  final PostCommentsReplyTarget? replyTarget;
  final String? nextCursor;
  final bool hasMore;

  PostCommentsState copyWith({
    List<PostCommentModel>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    String? errorMessage,
    PostCommentsReplyTarget? replyTarget,
    String? nextCursor,
    bool? hasMore,
    bool clearError = false,
    bool clearReplyTarget = false,
    bool clearCursor = false,
  }) {
    return PostCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      replyTarget:
          clearReplyTarget ? null : (replyTarget ?? this.replyTarget),
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
