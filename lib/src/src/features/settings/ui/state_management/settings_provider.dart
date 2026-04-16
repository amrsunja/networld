import 'dart:ui';

import 'package:hooks_riverpod/legacy.dart';
import 'package:brokies/src/src/core/utils/enums/app_theme_type.dart';
import 'package:brokies/src/src/core/utils/state_management/app_events.dart';
import 'package:brokies/src/src/core/utils/state_management/presenter.dart';
import 'package:brokies/src/src/core/utils/state_management/single_events.dart';

import '../../data/settings_repo.dart';
import 'settings_state.dart';

final settingsProvider = StateNotifierProvider<SettingsPresenter, SettingsState>(
	(ref) => SettingsPresenter(
		repo: ref.read(settingsRepoProvider),
		appEvents: ref.read(appEventProvider),
	)
);

class SettingsPresenter extends Presenter<SettingsState> {
	final SettingsRepo repo;
	final AppEvents appEvents;

	SettingsPresenter({
		required this.repo,
		required this.appEvents,
	}) : super(
		SettingsState(isLoading: false, data: null)
	);

	Future<void> initDatabase() async {
		final response = await repo.initDatabase();

		await response.when(
			(success) {
			},
			(error) async {
        appEvents.send(ShowErrorEvent(error));
        await Future.delayed(Duration(seconds: 1));
        await initDatabase();
			}
		);
	}

	Future<void> initLocalSettings() async {
		final response = await repo.getLocalSettings();

		response.when(
			(success) {
				state = state.copyWith(data: success);
			},
			(error) {
			}
		);
	}

	/// Persists [locale]. Pass `null` to follow the device language.
	Future<bool> changeAppLanguage(Locale? locale) async {
		final response = await repo.changeAppLanguage(locale);

		return response.when(
			(success) {
				state = state.copyWith(data: success);
				return true;
			},
			(error) {
				appEvents.send(ShowErrorEvent(error));
				return false;
			},
		);
	}

	Future<void> changeAppThemeMode(AppThemeType type) async {
		final response = await repo.changeAppThemeMode(type);

		response.when(
			(success) {
				state = state.copyWith(data: success);
			},
			(error) {
				appEvents.send(ShowErrorEvent(error));
			}
		);
	}
}
