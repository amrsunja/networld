import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/app_settings_model.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
	const factory SettingsState({
		required bool isLoading,
		required AppSettingsModel? data,
	}) = _SettingsState;
}
