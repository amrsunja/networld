import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/post/data/models/post_comment_model.dart';
import 'package:networld/src/src/features/core/post/data/post_comments_repo.dart';
import 'package:networld/src/src/features/core/social/ui/state_management/social_feed_provider.dart';

import 'post_comments_state.dart';

final postCommentsProvider = StateNotifierProvider.autoDispose
    .family<PostCommentsPresenter, PostCommentsState, String>(
  (ref, postId) => PostCommentsPresenter(
    postId: postId,
    repo: ref.read(postCommentsRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    socialFeed: ref.read(socialFeedProvider.notifier),
  ),
);

class PostCommentsPresenter extends StateNotifier<PostCommentsState> {
  PostCommentsPresenter({
    required this.postId,
    required this.repo,
    required this.appEvents,
    required this.locale,
    required this.socialFeed,
  }) : super(const PostCommentsState());

  final String postId;
  final PostCommentsRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;
  final SocialFeedNotifier socialFeed;

  Future<void> loadComments({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
        clearCursor: true,
        hasMore: true,
      );
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(
        isLoadingMore: state.comments.isNotEmpty,
        isLoading: state.comments.isEmpty,
        clearError: true,
      );
    }

    final cursor = refresh ? null : state.nextCursor;
    final res = await repo.getComments(postId, cursor: cursor);

    res.when(
      (result) {
        final newComments = result.comments;
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          comments: refresh ? newComments : [...state.comments, ...newComments],
          nextCursor: result.nextCursor,
          hasMore: result.hasMore,
        );
      },
      (err) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: err.toMessage(locale),
        );
      },
    );
  }

  void setReplyTarget(PostCommentModel comment) {
    state = state.copyWith(
      replyTarget: PostCommentsReplyTarget(
        commentId: comment.id,
        username: comment.author.username,
        parentCommentId: comment.parentCommentId,
      ),
    );
  }

  void clearReplyTarget() {
    state = state.copyWith(clearReplyTarget: true);
  }

  Future<bool> sendComment(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return false;

    final reply = state.replyTarget;
    String? parentCommentId;
    var contentToSend = text;
    if (reply != null) {
      parentCommentId = reply.parentCommentId ?? reply.commentId;
      contentToSend = '@${reply.username} $text';
    }

    state = state.copyWith(isSending: true, clearError: true);
    final res = await repo.createComment(
      postId: postId,
      content: contentToSend,
      parentCommentId: parentCommentId,
    );

    return await res.when(
      (_) async {
        socialFeed.bumpCommentsCountForPost(postId);
        state = state.copyWith(
          isSending: false,
          clearReplyTarget: true,
        );
        await loadComments(refresh: true);
        return true;
      },
      (err) async {
        state = state.copyWith(
          isSending: false,
          errorMessage: err.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
        return false;
      },
    );
  }

  Future<void> toggleLikeComment(String commentId) async {
    final commentIndex = _findCommentIndex(commentId);
    if (commentIndex == null) return;

    final (parentIdx, childIdx) = commentIndex;
    final parent = state.comments[parentIdx];

    if (childIdx == null) {
      _toggleParentLike(parentIdx, parent);
    } else {
      _toggleChildLike(parentIdx, parent, childIdx);
    }
  }

  void _toggleParentLike(int parentIdx, PostCommentModel parent) {
    final nextLiked = !parent.isLiked;
    final nextLikes =
        (parent.likesCount + (nextLiked ? 1 : -1)).clamp(0, 1 << 30);
    final updated = parent.copyWith(isLiked: nextLiked, likesCount: nextLikes);

    final list = [...state.comments];
    list[parentIdx] = updated;
    state = state.copyWith(comments: list);

    _sendLikeRequest(parent.id, nextLiked, () {
      final rollback = [...state.comments];
      rollback[parentIdx] = parent;
      state = state.copyWith(comments: rollback);
    });
  }

  void _toggleChildLike(
    int parentIdx,
    PostCommentModel parent,
    int childIdx,
  ) {
    final child = parent.children[childIdx];
    final nextLiked = !child.isLiked;
    final nextLikes =
        (child.likesCount + (nextLiked ? 1 : -1)).clamp(0, 1 << 30);
    final updatedChild =
        child.copyWith(isLiked: nextLiked, likesCount: nextLikes);

    final newChildren = [...parent.children];
    newChildren[childIdx] = updatedChild;
    final updatedParent = parent.copyWith(children: newChildren);

    final list = [...state.comments];
    list[parentIdx] = updatedParent;
    state = state.copyWith(comments: list);

    _sendLikeRequest(child.id, nextLiked, () {
      final rollback = [...state.comments];
      rollback[parentIdx] = parent;
      state = state.copyWith(comments: rollback);
    });
  }

  Future<void> _sendLikeRequest(
    String commentId,
    bool liked,
    void Function() onRollback,
  ) async {
    final res =
        await repo.setCommentLiked(commentId: commentId, liked: liked);
    res.when(
      (_) {},
      (err) {
        onRollback();
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }

  Future<void> deleteComment(String commentId) async {
    final delta = _countRemovedCommentsIfDeleted(commentId) ?? 1;

    final res = await repo.deleteComment(commentId);
    res.when(
      (_) {
        _removeCommentFromState(commentId);
        socialFeed.adjustCommentsCountForPost(postId, -delta);
        appEvents.send(
          ShowSuccessMessageEvent(locale.socialSnackbarCommentDeleted),
        );
      },
      (err) {
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }

  Future<void> reportComment(
    String commentId,
    ReportCategoryEnum category,
  ) async {
    final res = await repo.reportComment(
      commentId: commentId,
      category: category,
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

  int? _countRemovedCommentsIfDeleted(String commentId) {
    for (final p in state.comments) {
      if (p.id == commentId) {
        return 1 + p.children.length;
      }
      for (final c in p.children) {
        if (c.id == commentId) {
          return 1;
        }
      }
    }
    return null;
  }

  void _removeCommentFromState(String commentId) {
    final clearReply = _shouldClearReplyTargetForDeleted(commentId);

    for (var i = 0; i < state.comments.length; i++) {
      final p = state.comments[i];
      if (p.id == commentId) {
        final newList = [...state.comments]..removeAt(i);
        state = state.copyWith(
          comments: newList,
          clearReplyTarget: clearReply,
        );
        return;
      }
      final cIdx = p.children.indexWhere((c) => c.id == commentId);
      if (cIdx >= 0) {
        final newChildren = [...p.children]..removeAt(cIdx);
        final newList = [...state.comments];
        newList[i] = p.copyWith(children: newChildren);
        state = state.copyWith(
          comments: newList,
          clearReplyTarget: clearReply,
        );
        return;
      }
    }
  }

  bool _shouldClearReplyTargetForDeleted(String deletedId) {
    final rt = state.replyTarget;
    if (rt == null) return false;
    if (rt.commentId == deletedId) return true;
    for (final p in state.comments) {
      if (p.id == deletedId) {
        return p.children.any((c) => c.id == rt.commentId);
      }
    }
    return false;
  }

  /// Returns (parentIndex, childIndex?) for a given comment ID.
  (int, int?)? _findCommentIndex(String commentId) {
    for (var i = 0; i < state.comments.length; i++) {
      if (state.comments[i].id == commentId) return (i, null);
      for (var j = 0; j < state.comments[i].children.length; j++) {
        if (state.comments[i].children[j].id == commentId) return (i, j);
      }
    }
    return null;
  }
}
