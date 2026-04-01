import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/features/core/post/data/models/post_comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final postCommentsRemoteDatasourceProvider =
    Provider<PostCommentsRemoteDatasource>(
  (ref) => PostCommentsRemoteDatasource(),
);

class GetCommentsResult {
  const GetCommentsResult({
    required this.comments,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<PostCommentModel> comments;
  final String? nextCursor;
  final bool hasMore;
}

class PostCommentsRemoteDatasource {
  static const _getCommentsFn = 'get-comments';
  static const _createCommentFn = 'create-comment';
  static const _createCommentReportRpc = 'create_comment_report';

  Future<GetCommentsResult> getComments(
    String postId, {
    String? cursor,
    int limit = 20,
  }) async {
    final res = await supabase.functions.invoke(
      _getCommentsFn,
      body: {
        'post_id': postId,
        'limit': limit,
        'cursor': cursor,
      },
    );

    final data = Map<String, dynamic>.from((res.data as Map?) ?? {});
    if (data['success'] != true) {
      throw ServerException.fromErrorCode(data['error']?.toString());
    }

    final rawComments = (data['comments'] as List?) ?? [];
    final comments = rawComments
        .map((e) =>
            PostCommentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return GetCommentsResult(
      comments: comments,
      nextCursor: data['next_cursor'] as String?,
      hasMore: data['has_more'] == true,
    );
  }

  Future<void> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final body = <String, dynamic>{
        'post_id': postId,
        'content': content,
      };
      if (parentCommentId != null) {
        body['parent_comment_id'] = parentCommentId;
      }

      final res = await supabase.functions.invoke(
        _createCommentFn,
        body: body,
      );
      final data = Map<String, dynamic>.from((res.data as Map?) ?? {});
      if (data['success'] != true) {
        throw ServerException.fromErrorCode(data['error']?.toString());
      }
    } on FunctionException catch (e) {
      String? code;
      if (e.details is Map) {
        final d = Map<String, dynamic>.from(e.details as Map);
        code = d['error']?.toString() ?? d['code']?.toString();
      }
      throw ServerException.fromErrorCode(code);
    }
  }

  Future<void> setCommentLiked({
    required String commentId,
    required bool liked,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw ServerException.fromErrorCode('unauthorized');

    if (liked) {
      await supabase.from('comment_likes').insert({
        'user_id': userId,
        'comment_id': commentId,
      });
      return;
    }

    await supabase
        .from('comment_likes')
        .delete()
        .match({'user_id': userId, 'comment_id': commentId});
  }

  Future<void> deleteComment(String commentId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw ServerException.fromErrorCode('unauthorized');

    await supabase.from('comments').delete().eq('id', commentId);
  }

  Future<void> reportComment({
    required String commentId,
    required ReportCategoryEnum category,
  }) async {
    if (supabase.auth.currentUser == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }
    if (commentId.isEmpty) {
      throw ServerException.fromErrorCode('unknown');
    }

    await supabase.rpc(
      _createCommentReportRpc,
      params: {
        'p_comment_id': commentId,
        'p_category': category.dbValue,
      },
    );
  }
}
