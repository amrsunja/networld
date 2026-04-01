import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final socialFeedRemoteDatasourceProvider =
    Provider<SocialFeedRemoteDatasource>(
  (ref) => SocialFeedRemoteDatasource(),
);

class FeedPageResult {
  const FeedPageResult({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });

  final List<FeedPostModel> posts;
  final String? nextCursor;
  final bool hasMore;
}

class SocialFeedRemoteDatasource {
  static const _getFeedFn = 'get-feed';
  static const _likesTable = 'post_likes';
  static const _postsTable = 'posts';
  static const _createPostReportRpc = 'create_post_report';

  Future<FeedPageResult> fetchFeedPage({
    required int limit,
    String? cursor,
  }) async {
    try {
      final res = await supabase.functions.invoke(
        _getFeedFn,
        body: <String, dynamic>{
          'limit': limit,
          'cursor': cursor,
        },
      );

      final data = (res.data as Json?) ?? {};
      if (data['success'] != true) {
        final err = data['error']?.toString();
        throw ServerException.fromErrorCode(err);
      }

      final rawPosts = data['posts'];
      final list = rawPosts is List ? rawPosts : <dynamic>[];
      final posts = list
          .map((e) => FeedPostModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final nextCursor = data['next_cursor'] as String?;
      final hasMore = data['has_more'] == true;

      return FeedPageResult(
        posts: posts,
        nextCursor: nextCursor,
        hasMore: hasMore,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      String? code;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        code = m['error'] as String? ?? m['code'] as String?;
        if (code == null && m['message'] is String) {
          code = m['message'] as String?;
        }
      }
      throw ServerException.fromErrorCode(code);
    }
  }

  /// Inserts or deletes a row in [post_likes]. Server triggers should maintain [likes_count].
  Future<void> setPostLiked({
    required String postId,
    required bool liked,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }

    if (liked) {
      await supabase.from(_likesTable).upsert(<String, dynamic>{
        'post_id': postId,
        'user_id': user.id,
      });
    } else {
      await supabase
          .from(_likesTable)
          .delete()
          .match({'post_id': postId, 'user_id': user.id});
    }
  }

  Future<void> reportPost({
    required String postId,
    required ReportCategoryEnum category,
  }) async {
    if (supabase.auth.currentUser == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }
    if (postId.isEmpty) {
      throw ServerException.fromErrorCode('unknown');
    }

    await supabase.rpc(
      _createPostReportRpc,
      params: {
        'p_post_id': postId,
        'p_category': category.dbValue,
      },
    );
  }

  Future<void> deletePost(String postId) async {
    if (supabase.auth.currentUser == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }
    await supabase.from(_postsTable).delete().eq('id', postId);
  }
}
