enum NotificationTypeEnum {
  like_post,
  like_comment,
  comment,
  new_follower,
  reward_daily,
  reward_weekly,
  reward_monthly,
  ranking,
  system,
  moderation;

  static NotificationTypeEnum fromString(String value) {
    switch (value) {
      case 'like_post':
        return like_post;
      case 'like_comment':
        return like_comment;
      case 'comment':
        return comment;
      case 'new_follower':
        return new_follower;
      case 'reward_daily':
        return reward_daily;
      case 'reward_weekly':
        return reward_weekly;
      case 'reward_monthly':
        return reward_monthly;
      case 'ranking':
        return ranking;
      case 'system':
        return system;
      case 'moderation':
        return moderation;
      default:
        return system;
    }
  }

  String get dbValue => name;
}
