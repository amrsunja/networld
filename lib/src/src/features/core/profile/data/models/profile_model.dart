import 'package:equatable/equatable.dart';
import 'package:networld/src/src/core/utils/enums/networth_input_method_enum.dart';
import 'package:networld/src/src/core/utils/enums/currency_type_enum.dart';
import 'package:networld/src/src/core/utils/enums/rank_tier_enum.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

class ProfileModel extends Equatable {
  final String id;
  final String username;
  final num netWorth;
  final CurrencyType currency;
  final NetworthInputMethodEnum netWorthInputMethod;
  final int credits;
  final int xp;
  final int elo;
  final RankTierEnum rankTier;
  final int avatarId;
  final String? bio;
  final int? age;
  final String? city;
  final bool showAge;
  final bool showCity;
  final bool isVerified;
  final bool onboardingCompleted;
  final int followersCount;
  final int followingCount;
  final DateTime lastNetworthCalcAt;
  final DateTime nextFreeCalcAt;
  final DateTime createdAt;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.netWorth,
    required this.currency,
    required this.netWorthInputMethod,
    required this.credits,
    required this.xp,
    required this.elo,
    required this.rankTier,
    required this.avatarId,
    this.bio,
    this.age,
    this.city,
    required this.showAge,
    required this.showCity,
    required this.isVerified,
    required this.onboardingCompleted,
    this.followersCount = 0,
    this.followingCount = 0,
    required this.lastNetworthCalcAt,
    required this.nextFreeCalcAt,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Json json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      netWorth: _parseNum(json['net_worth']),
      currency: CurrencyType.fromString(
        (json['currency'] as String?) ?? 'USD',
      ),
      netWorthInputMethod: NetworthInputMethodEnum.fromString(
        (json['net_worth_input_method'] as String?) ?? 'manual',
      ),
      credits: (json['credits'] as int?) ?? 0,
      xp: (json['xp'] as int?) ?? 0,
      elo: (json['elo'] as int?) ?? 1000,
      rankTier: RankTierEnum.fromString(
        (json['rank_tier'] as String?) ?? 'Starter',
      ),
      avatarId: (json['avatar_id'] as int?) ?? 1,
      bio: json['bio'] as String?,
      age: json['age'] as int?,
      city: json['city'] as String?,
      showAge: (json['show_age'] as bool?) ?? false,
      showCity: (json['show_city'] as bool?) ?? false,
      isVerified: (json['is_verified'] as bool?) ?? false,
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
      followersCount: (json['followers_count'] as int?) ?? 0,
      followingCount: (json['following_count'] as int?) ?? 0,
      lastNetworthCalcAt: _parseDateTime(json['last_networth_calc_at']),
      nextFreeCalcAt: _parseDateTime(json['next_free_calc_at']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  static num _parseNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Json toJson() => {
        'id': id,
        'username': username,
        'net_worth': netWorth,
        'currency': currency.dbValue,
        'net_worth_input_method': netWorthInputMethod.dbValue,
        'credits': credits,
        'xp': xp,
        'elo': elo,
        'rank_tier': rankTier.dbValue,
        'avatar_id': avatarId,
        'bio': bio,
        'age': age,
        'city': city,
        'show_age': showAge,
        'show_city': showCity,
        'is_verified': isVerified,
        'onboarding_completed': onboardingCompleted,
        'followers_count': followersCount,
        'following_count': followingCount,
        'last_networth_calc_at': lastNetworthCalcAt.toIso8601String(),
        'next_free_calc_at': nextFreeCalcAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  ProfileModel copyWith({
    int? followersCount,
    int? followingCount,
  }) {
    return ProfileModel(
      id: id,
      username: username,
      netWorth: netWorth,
      currency: currency,
      netWorthInputMethod: netWorthInputMethod,
      credits: credits,
      xp: xp,
      elo: elo,
      rankTier: rankTier,
      avatarId: avatarId,
      bio: bio,
      age: age,
      city: city,
      showAge: showAge,
      showCity: showCity,
      isVerified: isVerified,
      onboardingCompleted: onboardingCompleted,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      lastNetworthCalcAt: lastNetworthCalcAt,
      nextFreeCalcAt: nextFreeCalcAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        netWorth,
        currency,
        netWorthInputMethod,
        credits,
        xp,
        elo,
        rankTier,
        avatarId,
        bio,
        age,
        city,
        showAge,
        showCity,
        isVerified,
        onboardingCompleted,
        followersCount,
        followingCount,
        lastNetworthCalcAt,
        nextFreeCalcAt,
        createdAt,
      ];
}
