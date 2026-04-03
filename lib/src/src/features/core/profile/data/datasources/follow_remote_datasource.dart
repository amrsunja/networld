import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception_type.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/profile/data/models/follow_user_model.dart';

final followRemoteDatasourceProvider = Provider<FollowRemoteDatasource>(
  (ref) => FollowRemoteDatasource(),
);

class FollowPageResult {
  final List<FollowUserModel> users;
  final String? nextCursor;
  final bool hasMore;

  const FollowPageResult({
    required this.users,
    this.nextCursor,
    this.hasMore = false,
  });
}

class FollowRemoteDatasource {
  static const _followsTable = 'follows';
  static const _getFollowersFn = 'get-followers';
  static const _getFollowingsFn = 'get-followings';

  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    final res = await supabase
        .from(_followsTable)
        .select('follower_id')
        .eq('follower_id', followerId)
        .eq('following_id', followingId)
        .maybeSingle();
    return res != null;
  }

  Future<void> follow(String followingId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const ServerException(ServerExceptionType.unauthorized);
    await supabase.from(_followsTable).insert({
      'follower_id': uid,
      'following_id': followingId,
    });
  }

  Future<void> unfollow(String followingId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const ServerException(ServerExceptionType.unauthorized);
    await supabase
        .from(_followsTable)
        .delete()
        .eq('follower_id', uid)
        .eq('following_id', followingId);
  }

  Future<FollowPageResult> fetchFollowers({
    required String userId,
    required int limit,
    String? cursor,
  }) async {
    final res = await supabase.functions.invoke(
      _getFollowersFn,
      body: <String, dynamic>{
        'user_id': userId,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final data = (res.data as Json?) ?? {};
    if (data['success'] != true) {
      throw ServerException.fromErrorCode(data['error'] as String?);
    }

    final rawUsers = (data['users'] as List<dynamic>?) ?? [];
    final users =
        rawUsers.map((e) => FollowUserModel.fromJson(e as Json)).toList();

    return FollowPageResult(
      users: users,
      nextCursor: data['next_cursor'] as String?,
      hasMore: (data['has_more'] as bool?) ?? false,
    );
  }

  Future<FollowPageResult> fetchFollowings({
    required String userId,
    required int limit,
    String? cursor,
  }) async {
    final res = await supabase.functions.invoke(
      _getFollowingsFn,
      body: <String, dynamic>{
        'user_id': userId,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final data = (res.data as Json?) ?? {};
    if (data['success'] != true) {
      throw ServerException.fromErrorCode(data['error'] as String?);
    }

    final rawUsers = (data['users'] as List<dynamic>?) ?? [];
    final users =
        rawUsers.map((e) => FollowUserModel.fromJson(e as Json)).toList();

    return FollowPageResult(
      users: users,
      nextCursor: data['next_cursor'] as String?,
      hasMore: (data['has_more'] as bool?) ?? false,
    );
  }
}
