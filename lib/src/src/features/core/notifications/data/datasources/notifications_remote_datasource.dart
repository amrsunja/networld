import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';
import 'package:brokies/src/src/features/core/notifications/data/models/notification_model.dart';
import 'package:brokies/src/src/features/core/notifications/data/models/notification_preferences_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

final notificationsRemoteDatasourceProvider =
    Provider<NotificationsRemoteDatasource>(
  (ref) => NotificationsRemoteDatasource(),
);

class NotificationsPageResult {
  const NotificationsPageResult({
    required this.notifications,
    this.nextCursor,
    required this.hasMore,
    required this.unreadCount,
  });

  final List<NotificationModel> notifications;
  final String? nextCursor;
  final bool hasMore;
  final int unreadCount;
}

class NotificationsRemoteDatasource {
  static const _notificationsTable = 'notifications';
  static const _preferencesTable = 'notification_preferences';
  static const _getNotificationsFn = 'get-notifications';

  Future<NotificationsPageResult> fetchNotifications({
    required int limit,
    String? cursor,
  }) async {
    try {
      final res = await supabase.functions.invoke(
        _getNotificationsFn,
        body: <String, dynamic>{
          'limit': limit,
          'cursor': cursor,
        },
      );

      final data = (res.data as Json?) ?? {};
      if (data['success'] != true) {
        final err = data['error']?.toString();
        throw ServerException.fromErrorCode(err);
      }

      final rawNotifs = data['notifications'];
      final list = rawNotifs is List ? rawNotifs : <dynamic>[];
      final notifications = list
          .map((e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return NotificationsPageResult(
        notifications: notifications,
        nextCursor: data['next_cursor'] as String?,
        hasMore: data['has_more'] == true,
        unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      String? code;
      if (details is Map) {
        final m = Map<String, dynamic>.from(details as Map);
        code = m['error'] as String? ?? m['code'] as String?;
      }
      throw ServerException.fromErrorCode(code);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }
    await supabase
        .from(_notificationsTable)
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  Future<NotificationPreferencesModel?> getPreferences() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from(_preferencesTable)
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return NotificationPreferencesModel.fromJson(
        response as Map<String, dynamic>);
  }

  Future<NotificationPreferencesModel> updatePreferences({
    required Map<String, dynamic> updates,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw ServerException.fromErrorCode('unauthorized');
    }

    final response = await supabase
        .from(_preferencesTable)
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

    return NotificationPreferencesModel.fromJson(
        response as Map<String, dynamic>);
  }
}
