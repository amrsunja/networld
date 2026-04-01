import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/network/supabase.dart';
import 'package:networld/src/src/core/utils/enums/report_category_enum.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/profile/data/profile_repo.dart';

import 'user_profile_state.dart';

/// Keyed by userId — each viewed profile gets isolated state.
final userProfileProvider = StateNotifierProvider.family<
    UserProfileNotifier, UserProfileState, String>(
  (ref, userId) => UserProfileNotifier(
    userId: userId,
    repo: ref.read(profileRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier({
    required this.userId,
    required this.repo,
    required this.appEvents,
    required this.locale,
  }) : super(const UserProfileState());

  static const _createProfileReportRpc = 'create_profile_report';

  final String userId;
  final ProfileRepo repo;
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
