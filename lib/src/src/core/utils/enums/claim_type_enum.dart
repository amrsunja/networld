enum ClaimTypeEnum {
  streak,
  survey_gift,
  mission,
  quiz_daily,
  quiz_weekly,
  quiz_monthly;

  static ClaimTypeEnum fromString(String value) {
    switch (value) {
      case 'streak':
        return streak;
      case 'survey_gift':
        return survey_gift;
      case 'mission':
        return mission;
      case 'quiz_daily':
        return quiz_daily;
      case 'quiz_weekly':
        return quiz_weekly;
      case 'quiz_monthly':
        return quiz_monthly;
      default:
        return streak;
    }
  }

  String get dbValue => name;
}
