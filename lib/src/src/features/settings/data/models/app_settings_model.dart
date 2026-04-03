import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:brokies/src/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:brokies/src/src/core/utils/enums/app_theme_type.dart';
import 'package:brokies/src/src/core/utils/typedefs.dart';

class AppSettingsModel extends Equatable {
	final Locale? locale;
	final AppThemeType themeMode;

	const AppSettingsModel({
		required this.locale,
		required this.themeMode,
	});

	factory AppSettingsModel.fromJson(Json json) {
		final langRaw = json[SQLiteConfig.languageCodeKey];
		final countryRaw = json[SQLiteConfig.countryCodeKey];
		final Locale? locale = langRaw == null
				? null
				: Locale(
						'$langRaw',
						countryRaw == null ? null : '$countryRaw',
					);
		return AppSettingsModel(
			locale: locale,
			themeMode: AppThemeType.fromJson(json[SQLiteConfig.themeModeKey]),
		);
	}

	Json toJson() => {
		SQLiteConfig.languageCodeKey: locale?.languageCode,
		SQLiteConfig.countryCodeKey: locale?.countryCode,
		SQLiteConfig.themeModeKey: themeMode.name,
	};

	static AppSettingsModel get getInitSettings => const AppSettingsModel(
		locale: null,
		themeMode: AppThemeType.system,
	);

  @override
  List<Object?> get props => [locale, themeMode];
}
