import 'package:brokies/src/src/features/core/notifications/data/models/notification_model.dart';

class NotificationsState {
  const NotificationsState({
    this.notifications = const [],
    this.cursor,
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.unreadCount = 0,
    this.errorMessage,
  });

  final List<NotificationModel> notifications;
  final String? cursor;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final int unreadCount;
  final String? errorMessage;

  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    String? cursor,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    int? unreadCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
