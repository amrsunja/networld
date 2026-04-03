import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';
import 'package:brokies/src/src/features/core/profile/data/datasources/follow_remote_datasource.dart';

import 'follow_list_state.dart';

/// Key = "$userId:followers" or "$userId:followings"
final followListProvider = StateNotifierProvider.family<
    FollowListNotifier, FollowListState, String>(
  (ref, key) {
    final parts = key.split(':');
    final userId = parts[0];
    final isFollowers = parts[1] == 'followers';
    return FollowListNotifier(
      userId: userId,
      isFollowers: isFollowers,
      datasource: ref.read(followRemoteDatasourceProvider),
      appEvents: ref.read(appEventProvider),
      locale: ref.read(l10nProvider),
    );
  },
);

class FollowListNotifier extends StateNotifier<FollowListState> {
  FollowListNotifier({
    required this.userId,
    required this.isFollowers,
    required this.datasource,
    required this.appEvents,
    required this.locale,
  }) : super(const FollowListState());

  static const _pageSize = 20;

  final String userId;
  final bool isFollowers;
  final FollowRemoteDatasource datasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> load({bool refresh = false}) async {
    if (!refresh && (state.isRefreshing || state.isLoadingMore)) return;
    if (!refresh && !state.hasMore && state.users.isNotEmpty) return;

    state = refresh
        ? state.copyWith(
            isRefreshing: true, clearError: true, clearCursor: true)
        : state.copyWith(isLoadingMore: true, clearError: true);

    final cursor = refresh ? null : state.cursor;
    final res = await Failure.exceptionsCatcher(
      () => isFollowers
          ? datasource.fetchFollowers(
              userId: userId, limit: _pageSize, cursor: cursor)
          : datasource.fetchFollowings(
              userId: userId, limit: _pageSize, cursor: cursor),
    );

    res.when(
      (page) {
        final merged = refresh ? page.users : [...state.users, ...page.users];
        state = state.copyWith(
          users: merged,
          cursor: page.nextCursor,
          hasMore: page.hasMore,
          isRefreshing: false,
          isLoadingMore: false,
        );
      },
      (err) {
        state = state.copyWith(
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: err.toMessage(locale),
        );
        appEvents.send(ShowErrorEvent(err, defaultMessage: err.toMessage(locale)));
      },
    );
  }
}
