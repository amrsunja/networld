import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

class PostCommentAuthorModel extends Equatable {
  const PostCommentAuthorModel({
    required this.id,
    required this.username,
    required this.avatarId,
    required this.isVerified,
    required this.rankTier,
    required this.netWorth,
  });

  final String id;
  final String username;
  final int avatarId;
  final bool isVerified;
  final RankTierEnum rankTier;
  final num netWorth;

  factory PostCommentAuthorModel.fromJson(Json json) {
    return PostCommentAuthorModel(
      id: (json['id'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      avatarId: (json['avatar_id'] as int?) ?? 1,
      isVerified: (json['is_verified'] as bool?) ?? false,
      rankTier: RankTierEnum.fromString(
        (json['rank_tier'] as String?) ?? 'Starter',
      ),
      netWorth: _parseNum(json['net_worth']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props =>
      [id, username, avatarId, isVerified, rankTier, netWorth];
}

class PostCommentModel extends Equatable {
  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.likesCount,
    required this.createdAt,
    required this.author,
    required this.isLiked,
    this.parentCommentId,
    this.children = const [],
  });

  final String id;
  final String postId;
  final String authorId;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final PostCommentAuthorModel author;
  final bool isLiked;
  final String? parentCommentId;
  final List<PostCommentModel> children;

  factory PostCommentModel.fromJson(Json json) {
    final profileRaw = json['profiles'];
    final profile = profileRaw is Map<String, dynamic>
        ? profileRaw
        : Map<String, dynamic>.from((profileRaw as Map?) ?? {});

    final childrenRaw = json['children'] as List?;
    final children = childrenRaw
            ?.map((e) =>
                PostCommentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [];

    return PostCommentModel(
      id: json['id'] as String,
      postId: (json['post_id'] as String?) ?? '',
      authorId: (json['author_id'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      likesCount: (json['likes_count'] as int?) ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
      author: PostCommentAuthorModel.fromJson(profile),
      isLiked: (json['is_liked'] as bool?) ?? false,
      parentCommentId: json['parent_comment_id'] as String?,
      children: children,
    );
  }

  PostCommentModel copyWith({
    int? likesCount,
    bool? isLiked,
    List<PostCommentModel>? children,
  }) {
    return PostCommentModel(
      id: id,
      postId: postId,
      authorId: authorId,
      content: content,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt,
      author: author,
      isLiked: isLiked ?? this.isLiked,
      parentCommentId: parentCommentId,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        content,
        likesCount,
        createdAt,
        author,
        isLiked,
        parentCommentId,
        children,
      ];
}
