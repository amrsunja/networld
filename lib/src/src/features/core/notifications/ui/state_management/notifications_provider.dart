import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:networld/src/src/features/core/notifications/data/models/notification_model.dart';

import 'notifications_state.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(
    datasource: ref.read(notificationsRemoteDatasourceProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier({
    required this.datasource,
    required this.appEvents,
    required this.locale,
  }) : super(const NotificationsState());

  static const _pageSize = 20;

  final NotificationsRemoteDatasource datasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (!refresh) {
      if (!state.hasMore) return;
      if (state.isLoadingMore) return;
      if (state.notifications.isEmpty) return;
    }
    if (state.isRefreshing) return;

    final cursorToUse = refresh ? null : state.cursor;

    if (refresh) {
      state = state.copyWith(
        isRefreshing: true,
        clearError: true,
        cursor: null,
        hasMore: true,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }

    try {
      final page = await datasource.fetchNotifications(
        limit: _pageSize,
        cursor: cursorToUse,
      );

      final notifications = refresh
          ? page.notifications
          : <NotificationModel>[
              ...state.notifications,
              ...page.notifications,
            ];

      state = state.copyWith(
        notifications: notifications,
        cursor: page.nextCursor,
        hasMore: page.hasMore,
        isRefreshing: false,
        isLoadingMore: false,
        unreadCount: page.unreadCount,
      );
    } on ServerException catch (e) {
      final failure = ServerFailure(exception: e);
      state = state.copyWith(
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: failure.toMessage(locale),
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final idx =
        state.notifications.indexWhere((n) => n.id == notificationId);
    if (idx < 0) return;

    final notification = state.notifications[idx];
    if (notification.isRead) return;

    final updated = notification.copyWith(isRead: true);
    final list = List<NotificationModel>.from(state.notifications);
    list[idx] = updated;
    final newUnread = (state.unreadCount - 1).clamp(0, state.unreadCount);
    state = state.copyWith(notifications: list, unreadCount: newUnread);

    try {
      await datasource.markAsRead(notificationId);
    } catch (_) {
      list[idx] = notification;
      state = state.copyWith(
        notifications: list,
        unreadCount: state.unreadCount + 1,
      );
    }
  }
}
