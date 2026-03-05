import 'dart:ui';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/errors/failures/failures.dart';
import 'package:networld/src/src/core/utils/enums/app_theme_type.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';

import 'datasources/settings_local_datasource.dart';
import 'models/app_settings_model.dart';

final settingsRepoProvider = Provider((ref) => SettingsRepo(
		localDatasource: ref.read(settingsLocalDataProvider),
));

class SettingsRepo {
	final SettingsLocalDatasource localDatasource;

	SettingsRepo({
		required this.localDatasource,
	});

  Future<SuccessOrError<void>> initDatabase() async {
		return await Failure.exceptionsCatcher(() async {
			return await localDatasource.initDatabase();
		});
  }

  Future<SuccessOrError<AppSettingsModel>> getLocalSettings() async {
		return await Failure.exceptionsCatcher(() async {
			return await localDatasource.getLocalSettings();
		});
  }

  Future<SuccessOrError<AppSettingsModel>> changeAppLanguage(Locale locale) async {
		return await Failure.exceptionsCatcher(() async {
			await localDatasource.changeAppLanguage(locale);
			return await localDatasource.getLocalSettings();
		});
  }

  Future<SuccessOrError<AppSettingsModel>> changeAppThemeMode(AppThemeType type) async {
		return await Failure.exceptionsCatcher(() async {
			await localDatasource.changeAppThemeMode(type);
			return await localDatasource.getLocalSettings();
		});
  }
}
