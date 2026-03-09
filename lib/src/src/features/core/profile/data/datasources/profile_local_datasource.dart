import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:networld/src/src/core/local/database/sqlite/sqlite_config.dart';
import 'package:networld/src/src/core/local/database/sqlite/sqlite_services.dart';
import 'package:networld/src/src/core/providers/local/sqlite_database_provider.dart';
import 'package:networld/src/src/core/utils/typedefs.dart';
import 'package:networld/src/src/features/core/profile/data/models/profile_model.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

final profileLocalDatasourceProvider = Provider<ProfileLocalDatasource>(
  (ref) => ProfileLocalDatasource(services: ref.read(sqliteDataBaseProvider)),
);

class ProfileLocalDatasource {
  final SQLiteServices services;

  ProfileLocalDatasource({required this.services});

  Future<void> saveProfile(String userId, ProfileModel profile) async {
    await services.initDatabase();
    final db = services.db;

    final data = jsonEncode(profile.toJson());
    await db.insert(
      SQLiteConfig.profilesTableName,
      {
        SQLiteConfig.profileUserIdKey: userId,
        SQLiteConfig.profileDataKey: data,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ProfileModel?> getProfile(String userId) async {
    await services.initDatabase();
    final db = services.db;

    final rows = await db.query(
      SQLiteConfig.profilesTableName,
      where: '${SQLiteConfig.profileUserIdKey} = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final data = rows.first[SQLiteConfig.profileDataKey] as String?;
    if (data == null) return null;

    final json = jsonDecode(data) as Json;
    return ProfileModel.fromJson(json);
  }
}
