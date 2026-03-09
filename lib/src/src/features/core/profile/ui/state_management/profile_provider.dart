import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';

import '../../data/profile_repo.dart';
import 'profile_state.dart';

final profileProvider = StateNotifierProvider<ProfilePresenter, ProfileState>(
  (ref) => ProfilePresenter(
    repo: ref.read(profileRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  ),
);

class ProfilePresenter extends Presenter<ProfileState> {
  final ProfileRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;

  ProfilePresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
  }) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await repo.getCurrentUserProfile();

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
}
