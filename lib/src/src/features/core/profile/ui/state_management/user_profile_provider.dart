import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/errors/failures/failures.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/network/supabase.dart';
import 'package:brokies/src/src/core/utils/enums/report_category_enum.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';
import 'package:brokies/src/src/features/core/profile/data/datasources/follow_remote_datasource.dart';
import 'package:brokies/src/src/features/core/profile/data/profile_repo.dart';

import 'user_profile_state.dart';

/// Keyed by userId — each viewed profile gets isolated state.
final userProfileProvider = StateNotifierProvider.family<
    UserProfileNotifier, UserProfileState, String>(
  (ref, userId) => UserProfileNotifier(
    userId: userId,
    repo: ref.read(profileRepoProvider),
    followDatasource: ref.read(followRemoteDatasourceProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier({
    required this.userId,
    required this.repo,
    required this.followDatasource,
    required this.appEvents,
    required this.locale,
  }) : super(const UserProfileState());

  static const _createProfileReportRpc = 'create_profile_report';

  final String userId;
  final ProfileRepo repo;
  final FollowRemoteDatasource followDatasource;
  final AppEvents appEvents;
  final AppLocale locale;

  Future<void> loadProfile() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await repo.getProfile(userId);

    response.when(
      (profile) {
        state = state.copyWith(
          isLoading: false,
          profile: profile,
          errorMessage: profile == null ? 'Profile not found' : null,
        );
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to load profile'),
        );
      },
    );
  }

  Future<void> checkFollowStatus() async {
    final currentUid = supabase.auth.currentUser?.id;
    if (currentUid == null || currentUid == userId) return;
    final res = await Failure.exceptionsCatcher(
      () => followDatasource.isFollowing(
        followerId: currentUid,
        followingId: userId,
      ),
    );
    res.when(
      (isFollowing) => state = state.copyWith(isFollowing: isFollowing),
      (_) {},
    );
  }

  Future<void> toggleFollow() async {
    if (state.isFollowLoading) return;
    final wasFollowing = state.isFollowing;
    final profile = state.profile;

    state = state.copyWith(
      isFollowing: !wasFollowing,
      isFollowLoading: true,
      profile: profile?.copyWith(
        followersCount:
            profile.followersCount + (wasFollowing ? -1 : 1),
      ),
    );

    final res = await Failure.exceptionsCatcher(
      () => wasFollowing
          ? followDatasource.unfollow(userId)
          : followDatasource.follow(userId),
    );

    res.when(
      (_) => state = state.copyWith(isFollowLoading: false),
      (err) {
        state = state.copyWith(
          isFollowing: wasFollowing,
          isFollowLoading: false,
          profile: profile,
        );
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }

  Future<void> reportProfile(ReportCategoryEnum category) async {
    final res = await Failure.exceptionsCatcher(() async {
      await supabase.rpc(
        _createProfileReportRpc,
        params: {
          'p_user_id': userId,
          'p_category': category.dbValue,
        },
      );
    });
    res.when(
      (_) {
        appEvents.send(
          ShowSuccessMessageEvent(locale.socialSnackbarReportSubmitted),
        );
      },
      (err) {
        appEvents.send(
          ShowErrorEvent(err, defaultMessage: err.toMessage(locale)),
        );
      },
    );
  }
}
