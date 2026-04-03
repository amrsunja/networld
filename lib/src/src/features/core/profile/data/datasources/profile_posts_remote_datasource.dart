import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/social/data/models/feed_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final profilePostsRemoteDatasourceProvider =
    Provider<ProfilePostsRemoteDatasource>(
  (ref) => ProfilePostsRemoteDatasource(),
);

class ProfilePostsPageResult {
  const ProfilePostsPageResult({
    required this.posts,
    this.nextCursor,
    required this.hasMore,
  });

  final List<FeedPostModel> posts;
  final String? nextCursor;
  final bool hasMore;
}

class ProfilePostsRemoteDatasource {
  static const _getUserPostsFn = 'get-user-posts';

  Future<ProfilePostsPageResult> fetchUserPosts({
    required String userId,
    required int limit,
    String? cursor,
  }) async {
    try {
      final res = await supabase.functions.invoke(
        _getUserPostsFn,
        body: <String, dynamic>{
          'user_id': userId,
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
          .map(
            (e) => FeedPostModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();

      final nextCursor = data['next_cursor'] as String?;
      final hasMore = data['has_more'] == true;

      return ProfilePostsPageResult(
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
}
