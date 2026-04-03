import 'package:equatable/equatable.dart';
import 'package:brokies/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:brokies/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/social/data/models/post_poll_option_model.dart';

/// Author snapshot as returned by `get-feed` (`profiles` join).
class FeedAuthorModel extends Equatable {
  final String username;
  final int avatarId;
  final RankTierEnum rankTier;
  final bool isVerified;
  final num netWorth;
  final CurrencyType currency;

  const FeedAuthorModel({
    required this.username,
    required this.avatarId,
    required this.rankTier,
    required this.isVerified,
    required this.netWorth,
    required this.currency,
  });

  factory FeedAuthorModel.fromJson(Json? json) {
    if (json == null) {
      return const FeedAuthorModel(
        username: '',
        avatarId: 1,
        rankTier: RankTierEnum.Starter,
        isVerified: false,
        netWorth: 0,
        currency: CurrencyType.usd,
      );
    }
    return FeedAuthorModel(
      username: (json['username'] as String?) ?? '',
      avatarId: (json['avatar_id'] as int?) ?? 1,
      rankTier: RankTierEnum.fromString(
        (json['rank_tier'] as String?) ?? 'Starter',
      ),
      isVerified: (json['is_verified'] as bool?) ?? false,
      netWorth: _parseNum(json['net_worth']),
      currency: CurrencyType.fromString(
        (json['currency'] as String?) ?? CurrencyType.usd.dbValue,
      ),
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
      [username, avatarId, rankTier, isVerified, netWorth, currency];
}

/// Single post row from Edge Function `get-feed`.
class FeedPostModel extends Equatable {
  final String id;
  final String? content;
  final String? imageUrl;
  final String postType;
  /// Poll options from `poll_options` JSON array (`PostPollOptionModel` shape).
  final List<PostPollOptionModel>? polls;
  final bool isBoosted;
  final DateTime? boostExpiresAt;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String authorId;
  final String feedSlot;
  final bool isLiked;
  final FeedAuthorModel author;

  const FeedPostModel({
    required this.id,
    this.content,
    this.imageUrl,
    required this.postType,
    this.polls,
    required this.isBoosted,
    this.boostExpiresAt,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.authorId,
    required this.feedSlot,
    required this.isLiked,
    required this.author,
  });

  factory FeedPostModel.fromJson(Json json) {
    final profilesRaw = json['profiles'];
    Json? profileMap;
    if (profilesRaw is Map) {
      profileMap = Map<String, dynamic>.from(profilesRaw as Map);
    }

    return FeedPostModel(
      id: json['id'] as String,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      postType: (json['post_type'] as String?) ?? 'standard',
      polls: _parsePolls(json['poll_options']),
      isBoosted: (json['is_boosted'] as bool?) ?? false,
      boostExpiresAt: _parseOptionalDate(json['boost_expires_at']),
      likesCount: (json['likes_count'] as int?) ?? 0,
      commentsCount: (json['comments_count'] as int?) ?? 0,
      createdAt: _parseDateTime(json['created_at']),
      authorId: json['author_id'] as String,
      feedSlot: (json['feed_slot'] as String?) ?? '',
      isLiked: (json['is_liked'] as bool?) ?? false,
      author: FeedAuthorModel.fromJson(profileMap),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseOptionalDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static List<PostPollOptionModel>? _parsePolls(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;
    final out = <PostPollOptionModel>[];
    for (final e in raw) {
      if (e is Map) {
        try {
          out.add(
            PostPollOptionModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        } catch (_) {
          // skip malformed entries
        }
      }
    }
    return out.isEmpty ? null : out;
  }

  FeedPostModel copyWith({
    String? id,
    String? content,
    String? imageUrl,
    String? postType,
    List<PostPollOptionModel>? polls,
    bool? isBoosted,
    DateTime? boostExpiresAt,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    String? authorId,
    String? feedSlot,
    bool? isLiked,
    FeedAuthorModel? author,
  }) {
    return FeedPostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      postType: postType ?? this.postType,
      polls: polls ?? this.polls,
      isBoosted: isBoosted ?? this.isBoosted,
      boostExpiresAt: boostExpiresAt ?? this.boostExpiresAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      authorId: authorId ?? this.authorId,
      feedSlot: feedSlot ?? this.feedSlot,
      isLiked: isLiked ?? this.isLiked,
      author: author ?? this.author,
    );
  }

  /// Display net worth in feed cards using author profile currency.
  CurrencyType get displayCurrency => author.currency;

  @override
  List<Object?> get props => [
        id,
        content,
        imageUrl,
        postType,
        polls,
        isBoosted,
        boostExpiresAt,
        likesCount,
        commentsCount,
        createdAt,
        authorId,
        feedSlot,
        isLiked,
        author,
      ];
}
