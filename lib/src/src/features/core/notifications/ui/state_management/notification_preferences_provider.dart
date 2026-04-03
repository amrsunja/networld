import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/errors/exceptions/server/server_exception.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';
import 'package:brokies/src/src/features/core/notifications/data/datasources/notifications_remote_datasource.dart';

import 'notification_preferences_state.dart';

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferencesState>(
  (ref) => NotificationPreferencesNotifier(
    datasource: ref.read(notificationsRemoteDatasourceProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferencesState> {
  NotificationPreferencesNotifier({
    required this.datasource,
    required this.appEvents,
    required this.locale,
  }) : super(const NotificationPreferencesState());

  final NotificationsRemoteDatasource datasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final prefs = await datasource.getPreferences();
      state = state.copyWith(isLoading: false, preferences: prefs);
    } on ServerException catch (e) {
      final failure = ServerFailure(exception: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.toMessage(locale),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> togglePreference(String key, bool value) async {
    final current = state.preferences;
    if (current == null) return;

    final optimistic = switch (key) {
      'like_post' => current.copyWith(likePost: value),
      'comment' => current.copyWith(comment: value),
      'new_follower' => current.copyWith(newFollower: value),
      'reward' => current.copyWith(reward: value),
      'ranking' => current.copyWith(ranking: value),
      'system' => current.copyWith(system: value),
      _ => current,
    };

    state = state.copyWith(preferences: optimistic);

    try {
      final updated = await datasource.updatePreferences(
        updates: {key: value},
      );
      state = state.copyWith(preferences: updated);
    } on ServerException catch (e) {
      state = state.copyWith(preferences: current);
      final failure = ServerFailure(exception: e);
      appEvents.send(
        ShowErrorEvent(failure, defaultMessage: failure.toMessage(locale)),
      );
    } catch (e) {
      state = state.copyWith(preferences: current);
      appEvents.send(
        ShowErrorEvent(null, defaultMessage: e.toString()),
      );
    }
  }
}
