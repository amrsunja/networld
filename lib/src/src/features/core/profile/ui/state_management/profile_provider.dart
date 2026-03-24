import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';

import '../../data/profile_repo.dart';
import '../../domain/profile_username_rules.dart';
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

  /// Validates [rawUsername], updates it on the server, and refreshes [state.profile].
  ///
  /// [validationError] is set for client-side rule violations only.
  /// [shouldPop] is true when the screen can close (saved, unchanged, or success path).
  Future<({bool shouldPop, String? validationError})> saveProfileUsername(
    String rawUsername,
  ) async {
    final validationError = validateProfileUsername(rawUsername, locale);
    if (validationError != null) {
      return (shouldPop: false, validationError: validationError);
    }

    final username = rawUsername.trim();
    if (username == state.profile?.username) {
      return (shouldPop: true, validationError: null);
    }

    state = state.copyWith(isSavingProfile: true);

    final response = await repo.updateUsername(username);

    return response.when(
      (profile) {
        state = state.copyWith(
          isSavingProfile: false,
          profile: profile,
        );
        appEvents.send(
          ShowSuccessMessageEvent(locale.profileUpdatedMessage),
        );
        return (shouldPop: true, validationError: null);
      },
      (error) {
        state = state.copyWith(isSavingProfile: false);
        appEvents.send(
          ShowErrorEvent(
            error,
            defaultMessage: 'Could not update username',
          ),
        );
        return (shouldPop: false, validationError: null);
      },
    );
  }

  /// Calls Edge Function `delete-account` with confirmation, then clears profile state.
  Future<bool> deleteAccount() async {
    final response = await repo.deleteMyAccount();
    return response.when(
      (_) {
        state = const ProfileState();
        return true;
      },
      (error) {
        appEvents.send(
          ShowErrorEvent(
            error,
            defaultMessage: 'Could not delete account',
          ),
        );
        return false;
      },
    );
  }
}
