import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/locale/l10n.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/presenter.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';

import '../../data/auth_repo.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthPresenter, AuthState>((ref) {
  return AuthPresenter(
    repo: ref.read(authRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
    ref: ref
  );
});

class AuthPresenter extends Presenter<AuthState> {
  final AuthRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;
  final Ref ref;

  AuthPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
    required this.ref,
  }) : super(
          AuthState(
            isGoogleLoading: false,
            isAppleLoading: false,
            isAuthorized: false,
          ),
        );

  Future<void> initAuth() async {
    final response = await repo.checkAuthStatus();

    response.when(
      (isAuth) {
        state = state.copyWith(
          isAuthorized: isAuth,
        );
      },
      (error) {
        state = state.copyWith(
          isAuthorized: false,
        );
      },
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isGoogleLoading: true);

    final response = await repo.loginWithGoogle();

    response.when(
      (success) {
        state = state.copyWith(
          isGoogleLoading: false,
          isAuthorized: true,
        );
      },
      (error) {
        state = state.copyWith(isGoogleLoading: false);
        appEvents.send(
          ShowErrorEvent(
            error,
            defaultMessage: 'Google login failed',
          ),
        );
      },
    );
  }

  Future<void> loginWithApple() async {
    appEvents.send(
      const ShowInfoMessageEvent('Apple login is not implemented yet'),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isGoogleLoading: true, isAppleLoading: true);

    final response = await repo.logout();

    response.when(
      (success) {
        state = state.copyWith(
          isGoogleLoading: false,
          isAppleLoading: false,
          isAuthorized: false,
        );
      },
      (error) {
        state = state.copyWith(isGoogleLoading: false, isAppleLoading: false);
        appEvents.send(
          ShowErrorEvent(
            error,
            defaultMessage: 'Logout failed',
          ),
        );
      },
    );
  }
}
