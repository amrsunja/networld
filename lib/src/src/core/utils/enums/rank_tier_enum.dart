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
}
