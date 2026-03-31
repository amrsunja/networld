import 'package:networld/src/src/core/locale/l10n.dart';

enum RankTierEnum {
  Starter,
  Builder,
  Scaler,
  Elite,
  Whale;

  static RankTierEnum fromString(String value) {
    switch (value) {
      case 'Starter':
        return RankTierEnum.Starter;
      case 'Builder':
        return RankTierEnum.Builder;
      case 'Scaler':
        return RankTierEnum.Scaler;
      case 'Elite':
        return RankTierEnum.Elite;
      case 'Whale':
        return RankTierEnum.Whale;
      default:
        return RankTierEnum.Starter;
    }
  }

  String get dbValue => name;

  static String localizedRankTier(RankTierEnum tier, AppLocale l10n) {
    switch (tier) {
      case RankTierEnum.Starter:
        return l10n.rankTierStarter;
      case RankTierEnum.Builder:
        return l10n.rankTierBuilder;
      case RankTierEnum.Scaler:
        return l10n.rankTierScaler;
      case RankTierEnum.Elite:
        return l10n.rankTierElite;
      case RankTierEnum.Whale:
        return l10n.rankTierWhale;
    }
  }
}
