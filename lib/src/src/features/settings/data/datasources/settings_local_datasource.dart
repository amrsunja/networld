import 'dart:ui';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:brokies/src/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:brokies/src/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:brokies/src/src/core/providers/local/sqlite_database_provider.dart';
import 'package:brokies/src/src/core/utils/enums/app_theme_type.dart';

import '../models/app_settings_model.dart';


final settingsLocalDataProvider = Provider((ref) =>
	SettingsLocalDatasource(services: ref.read(sqliteDataBaseProvider))
);


class SettingsLocalDatasource {
	final SQLiteServices services;

	SettingsLocalDatasource({required this.services});

  Future<void> initDatabase() async {
    await services.initDatabase();
  }

  Future<void> saveLocalSettings(AppSettingsModel newSettings) async {
    throw UnimplementedError();
  }

  Future<AppSettingsModel> getLocalSettings() async {
    await services.initDatabase();
    final dbInstance = services.db;

    final result = await dbInstance.query(
      SQLiteConfig.settingsTableName,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      // Should never happen, but safety net
      return AppSettingsModel.getInitSettings;
    }

    final map = result.first;

    return AppSettingsModel.fromJson(map);
  }

  /// [locale] is `null` to follow the device language (clears stored locale).
  Future<void> changeAppLanguage(Locale? locale) async {
    await services.initDatabase();
    final dbInstance = services.db;

    await dbInstance.update(
      SQLiteConfig.settingsTableName,
      {
        SQLiteConfig.languageCodeKey: locale?.languageCode,
        SQLiteConfig.countryCodeKey: locale?.countryCode,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

	Future<void> changeAppThemeMode(AppThemeType type) async {
    await services.initDatabase();
    final dbInstance = services.db;

    await dbInstance.update(
      SQLiteConfig.settingsTableName,
      {
        SQLiteConfig.themeModeKey: type.name,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}
