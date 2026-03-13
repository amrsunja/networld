import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:networld/src/src/core/locale/l10n.dart';
import 'package:networld/src/src/core/utils/state_management/app_events.dart';
import 'package:networld/src/src/core/utils/state_management/presenter.dart';
import 'package:networld/src/src/core/utils/state_management/single_events.dart';
import 'package:networld/src/src/features/core/powens/data/models/powens_session_model.dart';

import '../../data/powens_repo.dart';
import 'powens_state.dart';

final powensProvider =
    StateNotifierProvider<PowensPresenter, PowensState>((ref) {
  return PowensPresenter(
    repo: ref.read(powensRepoProvider),
    appEvents: ref.read(appEventProvider),
    locale: ref.read(l10nProvider),
  );
});

class PowensPresenter extends Presenter<PowensState> {
  final PowensRepo repo;
  final AppEvents appEvents;
  final AppLocale locale;

  PowensPresenter({
    required this.repo,
    required this.appEvents,
    required this.locale,
  }) : super(const PowensState());

  /// Returns the session data (webview URL and permanent token) on success.
  Future<PowensSessionModel?> createPowensSession() async {
    state = state.copyWith(isConnectingBank: true, errorMessage: null);

    final response = await repo.createPowensSession();

    PowensSessionModel? result;
    response.when(
      (data) {
        state = state.copyWith(isConnectingBank: false);
        result = data;
      },
      (error) {
        state = state.copyWith(
          isConnectingBank: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Could not start bank connection'),
        );
        result = null;
      },
    );
    return result;
  }

  /// Sets net worth manually. On success, [onSuccess] is called (e.g. navigate + refresh profile).
  Future<void> setManualNetWorth(
    double netWorth, {
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await repo.setManualNetWorth(netWorth);

    response.when(
      (_) {
        state = state.copyWith(isLoading: false);
        onSuccess?.call();
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to save net worth'),
        );
      },
    );
  }

  /// Recalculates net worth after a successful Powens connection.
  /// On success, [onSuccess] is called (e.g. navigate + refresh profile).
  Future<void> recalcNetWorthFromPowens({
    required String permanentToken,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await repo.recalcNetWorthFromPowens(permanentToken);

    response.when(
      (_) {
        state = state.copyWith(isLoading: false);
        onSuccess?.call();
      },
      (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toMessage(locale),
        );
        appEvents.send(
          ShowErrorEvent(error, defaultMessage: 'Failed to connect bank'),
        );
      },
    );
  }
}
