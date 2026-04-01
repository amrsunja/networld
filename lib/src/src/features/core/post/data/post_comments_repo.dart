import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/post/data/datasources/post_comments_remote_datasource.dart';

final postCommentsRepoProvider = Provider<PostCommentsRepo>(
  (ref) => PostCommentsRepo(
    remote: ref.read(postCommentsRemoteDatasourceProvider),
  ),
);

class PostCommentsRepo {
  PostCommentsRepo({required this.remote});

  final PostCommentsRemoteDatasource remote;

  Future<SuccessOrError<GetCommentsResult>> getComments(
    String postId, {
    String? cursor,
    int limit = 20,
  }) {
    return Failure.exceptionsCatcher(
      () => remote.getComments(postId, cursor: cursor, limit: limit),
    );
  }

  Future<SuccessOrError<void>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) {
    return Failure.exceptionsCatcher(
      () => remote.createComment(
        postId: postId,
        content: content,
        parentCommentId: parentCommentId,
      ),
    );
  }

  Future<SuccessOrError<void>> setCommentLiked({
    required String commentId,
    required bool liked,
  }) {
    return Failure.exceptionsCatcher(
      () => remote.setCommentLiked(commentId: commentId, liked: liked),
    );
  }

  Future<SuccessOrError<void>> deleteComment(String commentId) {
    return Failure.exceptionsCatcher(() => remote.deleteComment(commentId));
  }

  Future<SuccessOrError<void>> reportComment({
    required String commentId,
    required ReportCategoryEnum category,
  }) {
    return Failure.exceptionsCatcher(
      () => remote.reportComment(commentId: commentId, category: category),
    );
  }
}
