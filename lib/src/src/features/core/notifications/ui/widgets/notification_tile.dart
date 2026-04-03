import 'package:flutter/material.dart';
import 'package:brokies/src/src/core/design_system/app_ui.dart';
import 'package:brokies/src/src/core/locale/gen/app_localizations.dart';
import 'package:brokies/src/src/core/utils/enums/notification_type_enum.dart';
import 'package:brokies/src/src/features/core/notifications/data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.l10n,
  });

  final NotificationModel notification;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isUnread = !notification.isRead;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF111118) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isUnread
            ? Border(
                left: BorderSide(
                  color: UIColorsToken.pri350,
                  width: 2.5,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NotificationIcon(type: notification.type),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _notificationTitle(notification.type, l10n),
                  style: theme.typo.textSm.bold.copyWith(
                    color: UIColorsToken.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _notificationBody(notification, l10n),
                  style: theme.typo.textSm.regular.copyWith(
                    color: const Color(0xFF9E9EA8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _relativeTime(notification.createdAt, l10n),
                  style: theme.typo.textXs.regular.copyWith(
                    color: const Color(0xFF6B6B78),
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: UIColorsToken.pri350,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final NotificationTypeEnum type;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (type) {
      NotificationTypeEnum.like_post ||
      NotificationTypeEnum.like_comment =>
        (Icons.favorite_rounded, const Color(0xFFFF5D66)),
      NotificationTypeEnum.comment =>
        (Icons.chat_bubble_rounded, UIColorsToken.pri350),
      NotificationTypeEnum.new_follower =>
        (Icons.person_add_rounded, const Color(0xFF7C4DFF)),
      NotificationTypeEnum.reward_daily ||
      NotificationTypeEnum.reward_weekly ||
      NotificationTypeEnum.reward_monthly =>
        (Icons.card_giftcard_rounded, const Color(0xFF4CAF50)),
      NotificationTypeEnum.ranking =>
        (Icons.emoji_events_rounded, const Color(0xFFFFAB00)),
      NotificationTypeEnum.system =>
        (Icons.info_outline_rounded, const Color(0xFF42A5F5)),
      NotificationTypeEnum.moderation =>
        (Icons.shield_outlined, const Color(0xFFFF9800)),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 20),
    );
  }
}

String _notificationTitle(NotificationTypeEnum type, AppLocalizations l10n) {
  return switch (type) {
    NotificationTypeEnum.like_post => l10n.notificationTitleLikePost,
    NotificationTypeEnum.like_comment => l10n.notificationTitleLikeComment,
    NotificationTypeEnum.comment => l10n.notificationTitleComment,
    NotificationTypeEnum.new_follower => l10n.notificationTitleNewFollower,
    NotificationTypeEnum.reward_daily => l10n.notificationTitleRewardDaily,
    NotificationTypeEnum.reward_weekly => l10n.notificationTitleRewardWeekly,
    NotificationTypeEnum.reward_monthly => l10n.notificationTitleRewardMonthly,
    NotificationTypeEnum.ranking => l10n.notificationTitleRanking,
    NotificationTypeEnum.system => l10n.notificationTitleSystem,
    NotificationTypeEnum.moderation => l10n.notificationTitleModeration,
  };
}

String _notificationBody(NotificationModel n, AppLocalizations l10n) {
  return switch (n.type) {
    NotificationTypeEnum.like_post => l10n.notificationBodyLikePost,
    NotificationTypeEnum.like_comment => l10n.notificationBodyLikeComment,
    NotificationTypeEnum.comment => l10n.notificationBodyComment,
    NotificationTypeEnum.new_follower =>
      (n.refUsername != null && n.refUsername!.isNotEmpty)
          ? l10n.notificationBodyNewFollowerWith(n.refUsername!)
          : l10n.notificationBodyNewFollower,
    NotificationTypeEnum.reward_daily => l10n.notificationBodyRewardDaily,
    NotificationTypeEnum.reward_weekly => l10n.notificationBodyRewardWeekly,
    NotificationTypeEnum.reward_monthly => l10n.notificationBodyRewardMonthly,
    NotificationTypeEnum.ranking => l10n.notificationBodyRanking,
    NotificationTypeEnum.system => l10n.notificationBodySystem,
    NotificationTypeEnum.moderation => l10n.notificationBodyModeration,
  };
}

String _relativeTime(DateTime date, AppLocalizations l10n) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) {
    return l10n.socialRelativeFeedSecondsAgo(diff.inSeconds.clamp(1, 59));
  }
  if (diff.inMinutes < 60) {
    return l10n.socialRelativeFeedMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    return l10n.socialRelativeFeedHoursAgo(diff.inHours);
  }
  if (diff.inDays < 30) {
    return l10n.socialRelativeFeedDaysAgo(diff.inDays);
  }
  return l10n.socialRelativeFeedDate(date.day, date.month, date.year);
}
