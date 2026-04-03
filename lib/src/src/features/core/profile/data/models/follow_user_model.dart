import 'package:brokies/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';

class FollowUserModel {
  final String id;
  final String username;
  final int avatarId;
  final RankTierEnum rankTier;
  final bool isVerified;
  final num netWorth;
  final String currency;

  const FollowUserModel({
    required this.id,
    required this.username,
    required this.avatarId,
    required this.rankTier,
    required this.isVerified,
    required this.netWorth,
    required this.currency,
  });

  factory FollowUserModel.fromJson(Json json) {
    return FollowUserModel(
      id: json['id'] as String,
      username: (json['username'] as String?) ?? '',
      avatarId: (json['avatar_id'] as int?) ?? 1,
      rankTier: RankTierEnum.fromString(
        (json['rank_tier'] as String?) ?? 'Starter',
      ),
      isVerified: (json['is_verified'] as bool?) ?? false,
      netWorth: _parseNum(json['net_worth']),
      currency: (json['currency'] as String?) ?? 'EUR',
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
