enum CreditReasonEnum {
  post_creation,
  post_boost,
  comment_creation,
  quiz_entry,
  quiz_win,
  daily_reward,
  weekly_reward,
  monthly_reward,
  survey_gift,
  mission_reward,
  streak_reward,
  like_received_post,
  like_received_comment,
  avatar_purchase,
  networth_recalc,
  admin_grant,
  post_refund,
  iap_purchase;

  static CreditReasonEnum fromString(String value) {
    switch (value) {
      case 'post_creation':
        return post_creation;
      case 'post_boost':
        return post_boost;
      case 'comment_creation':
        return comment_creation;
      case 'quiz_entry':
        return quiz_entry;
      case 'quiz_win':
        return quiz_win;
      case 'daily_reward':
        return daily_reward;
      case 'weekly_reward':
        return weekly_reward;
      case 'monthly_reward':
        return monthly_reward;
      case 'survey_gift':
        return survey_gift;
      case 'mission_reward':
        return mission_reward;
      case 'streak_reward':
        return streak_reward;
      case 'like_received_post':
        return like_received_post;
      case 'like_received_comment':
        return like_received_comment;
      case 'avatar_purchase':
        return avatar_purchase;
      case 'networth_recalc':
        return networth_recalc;
      case 'admin_grant':
        return admin_grant;
      case 'post_refund':
        return post_refund;
      case 'iap_purchase':
        return iap_purchase;
      default:
        return post_creation;
    }
  }

  String get dbValue => name;
}
